
-- original from https://gist.github.com/ianjamieson/6e0e983839227fe57ac86ce8909d7cb9
--
-- draws a border around the focused window. Window filter events drive
-- updates; a slow timer resyncs in case events are dropped or late.

local log = hs.logger.new('winhighlight', 'info')

local highlight_color = {["red"] =  165/255.0, ["green"] = 208/255.0, ["blue"] = 168/255.0}
local highlight_border_width = 7

-- seconds between safety-net resyncs
local RESYNC_INTERVAL = 1.0

local current_highlight = nil   -- hs.drawing rectangle, or nil
local highlighted_id = nil      -- id of the window it surrounds

local function borderFrame(frame)
    return hs.geometry.rect(
        frame.x - highlight_border_width,
        frame.y - highlight_border_width,
        frame.w + (2 * highlight_border_width),
        frame.h + (2 * highlight_border_width))
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
-- so a stale border never survives
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
    local frame = borderFrame(win:frame())

    -- same window: just move/resize the existing border (no flicker)
    if current_highlight and id == highlighted_id then
        current_highlight:setFrame(frame)
        return
    end

    clearHighlight()
    current_highlight = hs.drawing.rectangle(frame)
    current_highlight:setStrokeColor(highlight_color)
    current_highlight:setStrokeWidth(highlight_border_width * 2)
    current_highlight:setRoundedRectRadii(10, 10)
    current_highlight:setFill(false)
    current_highlight:bringToFront(true) -- keep it above the window
    current_highlight:show()
    highlighted_id = id
    log.df("highlight window %s (%s)", id, win:title())
end

-- reconcile the border with whatever is actually focused right now
local function resync()
    local win = hs.window.focusedWindow()
    local id = win and win:id()
    if id ~= highlighted_id then
        log.df("resync: highlighted %s, focused %s", highlighted_id, id)
        highlightWindow(win)
    elseif win and current_highlight then
        local want = borderFrame(win:frame())
        local have = current_highlight:frame()
        if want.x ~= have.x or want.y ~= have.y or
           want.w ~= have.w or want.h ~= have.h then
            current_highlight:setFrame(want)
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

wf.default:subscribe(wf.windowMoved, function(win)
    if isHighlighted(win) then highlightWindow(win) end
end)

-- safety net for dropped/late window filter events. global so it isn't
-- garbage collected
winhighlightTimer = hs.timer.doEvery(RESYNC_INTERVAL, resync)
