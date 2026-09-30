
-- originally from: https://github.com/waigx/hammerspoon-config/blob/master/init.lua
-- this binds hyper-F to toggle maximize window. Pressing it again
-- restores the window's frame from before it was maximized.

local log = hs.logger.new('maximize', 'info')

-- fraction of the screen the maximized window occupies (centered)
local SCALE = 0.98

-- tolerance (px) when checking whether a window is still where we put
-- it; generous because some apps (terminals) snap to char cell sizes
local EPSILON = 30

-- per-window state, keyed by window id:
--   { original = <frame before maximizing>,
--     target   = <frame last requested> }
local state = {}

local function maxFrame(screenFrame)
   local w = screenFrame.w * SCALE
   local h = screenFrame.h * SCALE
   return hs.geometry.rect(
      screenFrame.x + (screenFrame.w - w) / 2,
      screenFrame.y + (screenFrame.h - h) / 2,
      w, h)
end

local function isNear(a, b)
   return math.abs(a.x - b.x) < EPSILON and
      math.abs(a.y - b.y) < EPSILON and
      math.abs(a.w - b.w) < EPSILON and
      math.abs(a.h - b.h) < EPSILON
end

local function toggleMaximize()
   local win = hs.window.focusedWindow()
   if not win then
      log.w("no focused window")
      return
   end

   local id = win:id()
   local cur = win:frame()
   local s = state[id]

   -- still where we maximized it: restore
   if s and isNear(cur, s.target) then
      log.f("restore window %d to %s", id, s.original)
      win:setFrame(s.original)
      state[id] = nil
      return
   end

   -- no saved state, or window was moved/resized since we maximized
   -- it: save the current frame and maximize
   local target = maxFrame(win:screen():frame())
   state[id] = { original = cur, target = target }
   log.f("maximize window %d to %s", id, target)
   win:setFrame(target)
end

hs.hotkey.bind(hyper, "F", toggleMaximize)
