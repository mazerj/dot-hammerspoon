-- About `hyper` key:
--   I'm using Karabiner-Elements to define caps lock as hyper
-- 
--   NOTE: emacs isn't happy if shift is included here - apparently
--   holding cmd-alt-ctrl-shift during startup will stop emacs from
--   loading init.el

print "*** INIT: ~/.hammerspoon/init.lua ***"

hyper = {"cmd", "ctrl", "alt"}

-- reload init file
hs.hotkey.bind(hyper, "R", function()
                  hs.reload()
                  -- note: this message doesn't clear because of reload causes
                  -- hammerspoon to loose some state:
                  -- hs.notify.new({title="Hammerspoon",
                  --               informativeText="Reloading Hammerspoon config"}):send()
end)

-----------------------------------------------------------------------

-- open remote vscode on raclette
hs.hotkey.bind(hyper, "V", function()
                  os.execute("~/scripts/code --remote ssh-remote+raclette /home/mazer/src/taut &")
end)

-- eject all media
hs.hotkey.bind(hyper, "E", function()
                  hs.notify.new({title="Hammerspoon",
                                 informativeText="Ejecting media"}):send()
                  os.execute("~/scripts/ejectall &")
end)

-- open journal stuff in notion
hs.hotkey.bind(hyper, "J", function()
                  os.execute("~/scripts/chromedef https://www.notion.so &")
end)

-- open terminal window
hs.hotkey.bind({"cmd"}, "1", function()
      --os.execute("open /Applications/iTerm.app &")
      -- this doesn't work if iterm not running:
      os.execute("~/scripts/newiterm3")              
end)

-- open personal chrome
function gochrome()
   os.execute("~/scripts/chromedef &")
end
hs.hotkey.bind(hyper, "G", gochrome)

-- open personal calendar
function gocal()
   os.execute("~/scripts/chromedef https://calendar.google.com &")
end
hs.hotkey.bind(hyper, "C", gocal)

-- open personal mail
function gomail()
   os.execute("~/scripts/chromedef https://mail.google.com &")
end
hs.hotkey.bind(hyper, "M", gomail)

-- open taut chrome
function gochromedec()
   os.execute("~/scripts/chromedec &")
end
hs.hotkey.bind(hyper, "D", gochromedec)

-----------------------------------------------------------------

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

bindResizeAndRestoreToKeys("F", getMaxWinFrame)
