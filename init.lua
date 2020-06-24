-- About `hyper` key:
--   I'm using Karabiner-Elements to define caps lock as hyper
-- 
--   NOTE: emacs isn't happy if shift is included here - apparently
--   holding cmd-alt-ctrl-shift during startup will stop emacs from
--   loading init.el

hyper = {"cmd", "ctrl", "alt"}

-- open console and reload init file
hs.hotkey.bind(hyper, "R", function()
		  hs.openConsole(True)
		  hs.reload()
end)

-- edit init file
hs.hotkey.bind(hyper, "H", function()
		  hs.execute("open -a Emacs.app --args ~/.hammerspoon/init.lua &")
end)

hs.hotkey.bind(hyper, "E", function()
		  hs.execute("~/scripts/ejectall &")
end)

hs.hotkey.bind(hyper, "J", function()
		  hs.execute("~/scripts/deft &")
end)

hs.hotkey.bind(hyper, "T", function()
		  hs.execute("~/scripts/todo &")
end)

hs.hotkey.bind({"cmd"}, "1", function()
      hs.execute("open /Applications/iTerm.app &")
end)

-- Note: chromedef runs chrome using "Default" profile
function gochrome()
   hs.execute("~/scripts/chromedef")
end
hs.hotkey.bind(hyper, "G", gochrome)
hs.hotkey.bind({}, "F3", gochrome)

function gocal()
   os.execute("~/scripts/chromedef https://calendar.google.com")
end
hs.hotkey.bind(hyper, "C", gocal)
hs.hotkey.bind({}, "F4", gocal)

function gomail()
   os.execute("~/scripts/chromedef https://mail.google.com")
end
hs.hotkey.bind(hyper, "M", gomail)


-- these window manipulation functions and bindings I nabbed from
-- some on-line examples...

hs.window.animationDuration = 0
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

function getFillLeftWinFrame()
   local curWin = hs.window.focusedWindow()
   local curWinFrame = curWin:frame()
   local maxFrame = curWin:screen():frame()
   curWinFrame.x = maxFrame.x
   curWinFrame.y = maxFrame.y
   curWinFrame.w = maxFrame.w / 2
   curWinFrame.h = maxFrame.h
   return curWinFrame
end

function getFillRightWinFrame()
   local curWin = hs.window.focusedWindow()
   local curWinFrame = curWin:frame()
   local maxFrame = curWin:screen():frame()
   curWinFrame.x = maxFrame.x + maxFrame.w / 2
   curWinFrame.y = maxFrame.y
   curWinFrame.w = maxFrame.w / 2
   curWinFrame.h = maxFrame.h
   return curWinFrame
end

function isPredefinedWinFrameSize()
   if isAlmostEqualToCurWinFrame(getMaxWinFrame()) or
      isAlmostEqualToCurWinFrame(getFillLeftWinFrame()) or
   isAlmostEqualToCurWinFrame(getFillRightWinFrame()) then
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

		     if isPredefinedWinFrameSize() and not isAlmostEqualToCurWinFrame(targetFrame) then
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

bindResizeAndRestoreToKeys("Up", getMaxWinFrame)
bindResizeAndRestoreToKeys("Left", getFillLeftWinFrame)
bindResizeAndRestoreToKeys("Right", getFillRightWinFrame)
