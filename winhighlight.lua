
-- original from https://gist.github.com/ianjamieson/6e0e983839227fe57ac86ce8909d7cb9


local highlight_color = {["red"] =  165/255.0, ["green"] = 208/255.0, ["blue"] = 168/255.0}
local highlight_border_width = 7

local current_highlight = nil

local function highlightWindow()
    -- Clear any existing highlight
    if current_highlight then
        current_highlight:delete()
        current_highlight = nil
    end

    -- Get the currently focused window
    local win = hs.window.focusedWindow()
    if not win then
        return
    end

    -- Get the frame of the focused window
    local frame = win:frame()

    highlightFrame = hs.geometry.rect(
        frame.x - highlight_border_width,
        frame.y - highlight_border_width,
        frame.w + (2 * highlight_border_width),
        frame.h + (2 * highlight_border_width)
        )

    -- Create the highlight rectangle
    current_highlight = hs.drawing.rectangle(highlightFrame)
    current_highlight:setStrokeColor(
        highlight_color
        )
    current_highlight:setStrokeWidth(highlight_border_width * 2)
    current_highlight:setRoundedRectRadii(10, 10)
    current_highlight:setFill(false)
    
    current_highlight:bringToFront(true) -- Ensure it's visible on top of the window
    current_highlight:show()
end

-- Bind the function to a hotkey (e.g., Ctrl + Alt + H)
hs.hotkey.bind(hyper, "H", highlightWindow)

-- Automatically remove the highlight when the focus changes
hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function()
    highlightWindow()
end)

hs.window.filter.default:subscribe(hs.window.filter.windowUnfocused, function()
    if current_highlight then
        current_highlight:delete()
        current_highlight = nil
    end
end)

-- Automatically remove the highlight, and recreate it when the window is moved
hs.window.filter.default:subscribe(hs.window.filter.windowMoved, function()
    if current_highlight then
        current_highlight:delete()
        current_highlight = nil
    end
    highlightWindow()
end)

-- end from https://gist.github.com/ianjamieson/6e0e983839227fe57ac86ce8909d7cb9 >>





