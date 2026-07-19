-- About `hyper` key:
--   I'm using Hyperkey.app to define caps lock as hyper
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

-- vscode shortcuts -- open taut repo on different machines

-- open taut dir in LOCAL vscode
hs.hotkey.bind(hyper, "V", function()
                  os.execute("~/scripts/code /Users/mazer/src/taut &")
end)

-- open taut dir in REMOTE vscode on storm
hs.hotkey.bind(hyper, "S", function()
                  os.execute("~/scripts/code --remote ssh-remote+storm /home/mazer/src/taut &")
end)

-- open taut dir in REMOTE vscode on storm
hs.hotkey.bind(hyper, "X", function()
                  os.execute("~/scripts/code --remote ssh-remote+storm . &")
end)


-----------------------------------------------------------------------

-- open journal in deft
hs.hotkey.bind(hyper, "J", function()
                  os.execute("~/scripts/deft &")
end)

-- open terminal window
hs.hotkey.bind({"cmd"}, "1", function()
      --os.execute("open /Applications/iTerm.app &")
      -- this doesn't work if iterm not running:
      os.execute("~/scripts/newiterm3")              
end)

-- open personal/default chrome
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
   os.execute("~/scripts/chromedec https://mail.google.com &")
end
hs.hotkey.bind(hyper, "M", gomail)

-- open taut chrome
function gochromedec()
   os.execute("~/scripts/chromedec &")
end
hs.hotkey.bind(hyper, "D", gochromedec)

-- open taut notes
function notes()
   os.execute("~/scripts/chromedec https://docs.google.com/document/d/1mrSpHbJ2xw90aBl-NA1tujhg-VYPuIr3LYrTDSv38Zc/edit?usp=drive_link &")
end
hs.hotkey.bind(hyper, "T", notes)

-- maximize window M-F
require('maximize')
require('winhighlight')

-- EjectMenu setup
hs.loadSpoon("EjectMenu")
spoon.EjectMenu:bindHotkeys({
                        ejectAll = {hyper, "E"}
        })
-- spoon.show_in_menubar = true
-- spoon.EjectMenu:start()

