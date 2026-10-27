
-- original from https://gist.github.com/ianjamieson/6e0e983839227fe57ac86ce8909d7cb9
--
-- highlights the focused window, either by covering its titlebar with
-- translucent hazard stripes or by drawing a border around its frame
-- (see HIGHLIGHT_MODE). Window filter events drive updates; a slow timer
-- resyncs in case events are dropped or late.

local log = hs.logger.new('winhighlight', 'info')

-- "titlebar" or "frame"
local HIGHLIGHT_MODE = "titlebar"

-- titlebar hazard stripes: 45 degree yellow bands with clear gaps,
-- drawn translucent so the title stays readable
local stripe_yellow = {["red"] = 1.0, ["green"] = 0.8, ["blue"] = 0.0}
local stripe_width = 30
local stripe_alpha = 0.4
local border_color = {["red"] = 1.0, ["green"] = 0.5, ["blue"] = 0.0}
local highlight_border_width = 4

-- standard macOS titlebar height, used when the AX lookup fails
local DEFAULT_TITLEBAR_HEIGHT = 28

-- cap on how long an AX query may block (a hung app would otherwise
-- stall hammerspoon for the system default of several seconds)
local AX_TIMEOUT = 0.25

-- seconds between safety-net resyncs
local RESYNC_INTERVAL = 1.0

local current_highlight = nil   -- hs.canvas, or nil
local highlighted_id = nil      -- id of the window it marks

-- window id -> titlebar height. looked up once per window and assumed
-- not to change
local titlebar_heights = {}

-- the traffic-light buttons are vertically centred in the titlebar
-- (including unified toolbars), so the height is twice the distance
-- from the window top to the close button's centre
local function queryTitlebarHeight(win)
    local axwin = hs.axuielement.windowElement(win)
    if not axwin then return nil, "no AX element" end
    axwin:setTimeout(AX_TIMEOUT)
    local wpos = axwin:attributeValue("AXPosition")
    local wsize = axwin:attributeValue("AXSize")
    if not (wpos and wsize) then return nil, "no window position/size" end
    local close = axwin:attributeValue("AXCloseButton")
    if not close then return nil, "no close button" end
    local cpos = close:attributeValue("AXPosition")
    local csize = close:attributeValue("AXSize")
    if not (cpos and csize) then return nil, "no close button position/size" end
    local h = 2 * (cpos.y + csize.h / 2 - wpos.y)
    if h <= 0 or h > wsize.h then
        return nil, string.format("implausible height %.1f", h)
    end
    return h
end

local function titlebarHeight(win)
    local id = win:id()
    local h = id and titlebar_heights[id]
    if h then return h end

    local t0 = hs.timer.absoluteTime()
    local ok, res, err = pcall(queryTitlebarHeight, win)
    local ms = (hs.timer.absoluteTime() - t0) / 1e6
    if not ok then
        err, res = res, nil
    end
    if res then
        log.f("titlebar height %.1f for %s (%s) in %.2f ms",
            res, id, win:title(), ms)
    else
        res = DEFAULT_TITLEBAR_HEIGHT
        log.f("titlebar lookup failed for %s (%s) in %.2f ms: %s; using %d",
            id, win:title(), ms, tostring(err), res)
    end
    -- failures are cached too, so a misbehaving app isn't re-queried
    -- on every resync
    if id then titlebar_heights[id] = res end
    return res
end

local function titlebarFrame(win)
    local frame = win:frame()
    return hs.geometry.rect(
        frame.x, frame.y, frame.w, math.min(titlebarHeight(win), frame.h))
end

-- canvas elements clip to the canvas, so only the inner half of
-- the stroke is visible. expand the frame by half the width and double
-- the stroke so the visible band straddles the window edge (and its
-- resize hot zone): width/2 outside, width/2 inside
local function borderFrame(win)
    local frame = win:frame()
    local half = highlight_border_width / 2
    return hs.geometry.rect(
        frame.x - half,
        frame.y - half,
        frame.w + highlight_border_width,
        frame.h + highlight_border_width)
end

-- stripes use absolute coordinates, so resizing the canvas reveals or
-- clips them rather than stretching them. they're drawn wide enough for
-- the widest screen so a resize never needs a rebuild
local function styleTitlebar(canvas)
    local frame = canvas:frame()
    local h = frame.h
    local span = frame.w
    for _, screen in ipairs(hs.screen.allScreens()) do
        span = math.max(span, screen:fullFrame().w)
    end
    -- start one titlebar height left of the origin so the slanted first
    -- band covers the left edge
    for x = -h, span, 2 * stripe_width do
        canvas[#canvas + 1] = {
            type = "segments", closed = true, action = "fill",
            fillColor = stripe_yellow,
            coordinates = {
                { x = x,                    y = h },
                { x = x + stripe_width,     y = h },
                { x = x + stripe_width + h, y = 0 },
                { x = x + h,                y = 0 },
            },
        }
    end
    canvas:alpha(stripe_alpha)
end

local function styleBorder(canvas)
    canvas[1] = {
        type = "rectangle", action = "stroke",
        strokeColor = border_color,
        strokeWidth = highlight_border_width * 2,
    }
end

local MODES = {
    titlebar = { frame = titlebarFrame, style = styleTitlebar },
    frame    = { frame = borderFrame,   style = styleBorder },
}

local mode = MODES[HIGHLIGHT_MODE]
if not mode then
    log.ef("unknown HIGHLIGHT_MODE %q, using titlebar", tostring(HIGHLIGHT_MODE))
    mode = MODES.titlebar
end

local function clearHighlight()
    if current_highlight then
        current_highlight:delete()
        current_highlight = nil
    end
    highlighted_id = nil
end

-- true when event window `win` is the one currently highlighted. a
-- destroyed window may no longer report an id; treat that as a match
-- so a stale highlight never survives
local function isHighlighted(win)
    if not highlighted_id then return false end
    local id = win and win:id()
    return id == nil or id == highlighted_id
end

local function highlightWindow(win)
    if not win or not win:isStandard() then
        clearHighlight()
        return
    end

    local id = win:id()
    local frame = mode.frame(win)

    -- same window: just move/resize the existing highlight (no flicker)
    if current_highlight and id == highlighted_id then
        current_highlight:frame(frame)
        return
    end

    clearHighlight()
    current_highlight = hs.canvas.new(frame)
    mode.style(current_highlight)
    current_highlight:bringToFront(true) -- keep it above the window
    current_highlight:show()
    highlighted_id = id
    log.df("highlight window %s (%s)", id, win:title())
end

-- reconcile the highlight with whatever is actually focused right now
local function resync()
    local win = hs.window.focusedWindow()
    local id = win and win:id()
    if id ~= highlighted_id then
        log.df("resync: highlighted %s, focused %s", highlighted_id, id)
        highlightWindow(win)
    elseif win and current_highlight then
        local want = mode.frame(win)
        local have = current_highlight:frame()
        if want.x ~= have.x or want.y ~= have.y or
           want.w ~= have.w or want.h ~= have.h then
            current_highlight:frame(want)
        end
    end
end

hs.hotkey.bind(hyper, "H", resync)

local wf = hs.window.filter

-- highlight the window the event is about, not focusedWindow(), which
-- can still report the previous window when this fires
wf.default:subscribe(wf.windowFocused, function(win) highlightWindow(win) end)

-- only clear if the event concerns the highlighted window; unfocus of
-- the old window can arrive after focus of the new one
wf.default:subscribe(
    { wf.windowUnfocused, wf.windowDestroyed, wf.windowMinimized,
      wf.windowHidden, wf.windowNotVisible },
    function(win)
        if isHighlighted(win) then clearHighlight() end
    end)

wf.default:subscribe(wf.windowDestroyed, function(win)
    local id = win and win:id()
    if id then titlebar_heights[id] = nil end
end)

wf.default:subscribe(wf.windowMoved, function(win)
    if isHighlighted(win) then highlightWindow(win) end
end)

-- safety net for dropped/late window filter events. global so it isn't
-- garbage collected
winhighlightTimer = hs.timer.doEvery(RESYNC_INTERVAL, resync)
