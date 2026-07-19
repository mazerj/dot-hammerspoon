
-- from: https://github.com/waigx/hammerspoon-config/blob/master/init.lua
-- this binds hyper-F to toggle maximize window

previousFrameSizes = {}

function isAlmostEqualToCurWinFrame(geo)
   local epsilon = 5
   local curWin = hs.window.focusedWindow()
   local curWinFrame = curWin:frame()
   if math.abs(curWinFrame.x - geo.x) < epsilon and
      math.abs(curWinFrame.y - geo.y) < epsilon and
      math.abs(curWinFrame.w - geo.w) < epsilon and
      math.abs(curWinFrame.h - geo.h) < epsilon then
      return true
   else
      return false
   end
end

function getMaxWinFrame()
   local curWin = hs.window.focusedWindow()
   return curWin:screen():frame()
end

function getQuarterWinFrame()
   local curWin = hs.window.focusedWindow()
   local curWinFrame = curWin:frame()
   local maxFrame = curWin:screen():frame()
   curWinFrame.x = maxFrame.x
   curWinFrame.y = maxFrame.y
   curWinFrame.w = maxFrame.w / 2
   curWinFrame.h = maxFrame.h / 2
   return curWinFrame
end

function isPredefinedWinFrameSize()
   if isAlmostEqualToCurWinFrame(getMaxWinFrame())
      or isAlmostEqualToCurWinFrame(getQuarterWinFrame())
   then
      return true
   else
      return false
   end
end

function bindResizeAndRestoreToKeys(key, resize_frame_fn)
   hs.hotkey.bind(hyper, key, function()
                     local curWin = hs.window.focusedWindow()
                     local curWinFrame = curWin:frame()
                     local targetFrame = resize_frame_fn()

                     if isPredefinedWinFrameSize() and
                        not isAlmostEqualToCurWinFrame(targetFrame) then
                        curWin:setFrame(targetFrame)
                     elseif previousFrameSizes[curWin:id()] then
                        curWin:setFrame(previousFrameSizes[curWin:id()])
                        previousFrameSizes[curWin:id()] = nil
                     else
                        previousFrameSizes[curWin:id()] = curWinFrame
                        curWin:setFrame(targetFrame)
                     end
   end)
end

bindResizeAndRestoreToKeys("F", getMaxWinFrame)
bindResizeAndRestoreToKeys("Q", getQuarterWinFrame)
