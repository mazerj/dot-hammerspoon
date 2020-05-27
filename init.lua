--[[

This is a configuration for Hammerspoon:
- reload config: cmd-ctrl-alt-R
- window layout management:
   - cmd-ctrl-alt-up: Toggle current window to maximize;
   - cmd-ctrl-alt-left: Toggle current window to left/restore;
   - cmd-ctrl-alt-right: Toggle current window to right/restore;
- eject all: cmd-ctrl-alt-E
- mail: cmd-ctrl-alt-M
- journal/deft: cmd-ctrl-alt-J
- chrome: F3 (note: fn-unshifted using FunctionFlip)
- calendar: F4 (note: fn-unshifted using FunctionFlip)

--]]


--hs.logger.defaultLogLevel("debug")


--allMods = {"cmd", "ctrl", "alt"}

-- Karabiner-Elements used to define caps lock:
hyper = {"cmd", "ctrl", "alt", "shift"}

-- quickly reload config:
hs.hotkey.bind(hyper, "R", function()
		  hs.reload()
		  hs.openConsole(True)
		  hs.notify.new({title="Hammerspoon",
				 autoWithdraw=true,
				 informativeText="Config Reloaded"}):send()
end)

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

hs.hotkey.bind(hyper, "E", function()
		  os.execute("~/scripts/ejectall &")
end)

hs.hotkey.bind(hyper, "J", function()
		  os.execute("~/scripts/deft &")
end)

hs.hotkey.bind(hyper, "T", function()
		  os.execute("~/scripts/todo &")
end)

-- quick markdown preview of paste buffer contents
hs.hotkey.bind(hyper, "P", function()
		  os.execute("(pbpaste >/tmp/temp.md && open -a Markoff /tmp/temp.md) &")
end)

hs.hotkey.bind({}, "F3", function()
      os.execute([["/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "--profile-directory=Default"]]);
end)


hs.hotkey.bind({}, "F4", function()
      os.execute([["/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "--profile-directory=Default" "https://calendar.google.com" ]]);
end)

hs.hotkey.bind(hyper, "M", function()
	os.execute([["/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "--profile-directory=Default" "https://mail.google.com" ]]);
end)

hs.hotkey.bind({"cmd"}, "1", function()
      os.execute("open /Applications/iTerm.app &")
end)

--[[
hs.hotkey.bind({"cmd"}, "1", function()
      -- if iTerm is running, open new window. Otherwise start new instance
      local term = hs.appfinder.appFromName("iTerm2")
      if term then
	 term:selectMenuItem({"Shell", "New Window"})	 
      else
	 hs.application.launchOrFocus("iTerm")
      end
end)
--]]

