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

-- open personal mail
function gomail()
    os.execute("~/scripts/chromedef https://mail.google.com &")
    os.execute("~/scripts/chromedec https://mail.google.com &")
end
hs.hotkey.bind(hyper, "M", gomail)

-- EjectMenu setup
hs.loadSpoon("EjectMenu")
spoon.EjectMenu:bindHotkeys({
    ejectAll = {hyper, "E"}
})
-- uncomment to show eject all in menubar:
--  spoon.show_in_menubar = true
--  spoon.EjectMenu:start()

-- maximize window hyper-F
require('maximize')

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

