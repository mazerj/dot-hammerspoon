
-- << start from https://gist.github.com/ianjamieson/6e0e983839227fe57ac86ce8909d7cb9

local highlight = nil

local function highlightWindow()
    -- Clear any existing highlight
    if highlight then
        highlight:delete()
        highlight = nil
    end

    -- Get the currently focused window
    local win = hs.window.focusedWindow()
    if not win then
        return
    end

    -- Get the frame of the focused window
    local frame = win:frame()

    border_width = 7
    highlightFrame = hs.geometry.rect(
        frame.x - border_width,
        frame.y - border_width,
        frame.w + (2 * border_width),
        frame.h + (2 * border_width)
        )
    

    -- Create the highlight rectangle
    highlight = hs.drawing.rectangle(highlightFrame)
    highlight:setStrokeColor(
        {["red"] =  165/255.0, ["green"] = 208/255.0, ["blue"] = 168/255.0}
        )
    highlight:setStrokeWidth(border_width * 2)
    highlight:setRoundedRectRadii(10, 10)
    highlight:setFill(false)
    
    highlight:bringToFront(true) -- Ensure it's visible on top of the window
    highlight:show()
end

-- Bind the function to a hotkey (e.g., Ctrl + Alt + H)
hs.hotkey.bind(hyper, "H", highlightWindow)

-- Automatically remove the highlight when the focus changes
hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function()
    highlightWindow()
end)

hs.window.filter.default:subscribe(hs.window.filter.windowUnfocused, function()
    if highlight then
        highlight:delete()
        highlight = nil
    end
end)

-- Automatically remove the highlight, and recreate it when the window is moved
hs.window.filter.default:subscribe(hs.window.filter.windowMoved, function()
    if highlight then
        highlight:delete()
        highlight = nil
    end
    highlightWindow()
end)

-- end from https://gist.github.com/ianjamieson/6e0e983839227fe57ac86ce8909d7cb9 >>





