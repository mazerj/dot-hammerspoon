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
end)

-- open journal in deft
hs.hotkey.bind(hyper, "J", function()
                               os.execute("~/scripts/deft &")
end)

-- open terminal window
hs.hotkey.bind({"cmd"}, "1", function()
                                 os.execute("~/scripts/newiterm3")              
end)

-- open personal/default chrome
hs.hotkey.bind(hyper, "G", function()
                               os.execute("~/scripts/chromedef &")
end)

-- open personal calendar
hs.hotkey.bind(hyper, "C", function()
                               os.execute("~/scripts/chromedef https://calendar.google.com &")
end)

-- open mail
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


-- WARNING: this generates
-- "EjectMenu setupject Menu: Error ejecting volume /Volumes/time2..."
--  I think it's because there are multiple volumes on one drive and they all get ejected
-- on the first ejection and then it errors trying to eject the second..
hs.loadSpoon("EjectMenu")

-- show eject all in menubar:
spoon.show_in_menubar = true
spoon.EjectMenu:start()

-- bind ejectAll to hyper-E
-- spoon.EjectMenu:bindHotkeys({
--     ejectAll = {hyper, "E"}
-- })


-- maximize window hyper-F
require('maximize')

-- quadrant placement hyper-1..4
require('quadrants')

-- automatically highlight border of focused window
require('winhighlight')


-- only do this on work computers:

hostname = hs.host.localizedName()
if hostname == 'bridger' then
    print "loading taut stuff"
    require('taut')
else
    print "skipped taut stuff"
end

