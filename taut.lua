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

