
-- binds hyper-1..4 to move/resize the focused window into a screen
-- quadrant (UL, UR, LL, LR). Pressing the same key again restores the
-- window's frame from before the first quadrant move. Switching
-- between quadrants keeps the original frame for the eventual restore.

local log = hs.logger.new('quadrants', 'info')

-- fraction of each quadrant the window occupies (centered in it)
local SCALE = 0.95

-- tolerance (px) when checking whether a window is still where we put
-- it; generous because some apps (terminals) snap to char cell sizes
local EPSILON = 30

-- quadrant offsets in units of half-screen
local QUADRANTS = {
   ["1"] = { name = "upper-left",  col = 0, row = 0 },
   ["2"] = { name = "upper-right", col = 1, row = 0 },
   ["3"] = { name = "lower-left",  col = 0, row = 1 },
   ["4"] = { name = "lower-right", col = 1, row = 1 },
}

-- per-window state, keyed by window id:
--   { original = <frame before first quadrant move>,
--     key      = <quadrant key last applied>,
--     target   = <frame last requested> }
local state = {}

local function quadrantFrame(screenFrame, q)
   local qw = screenFrame.w / 2
   local qh = screenFrame.h / 2
   local w = qw * SCALE
   local h = qh * SCALE
   return hs.geometry.rect(
      screenFrame.x + q.col * qw + (qw - w) / 2,
      screenFrame.y + q.row * qh + (qh - h) / 2,
      w, h)
end

local function isNear(a, b)
   return math.abs(a.x - b.x) < EPSILON and
      math.abs(a.y - b.y) < EPSILON and
      math.abs(a.w - b.w) < EPSILON and
      math.abs(a.h - b.h) < EPSILON
end

local function toggleQuadrant(key)
   local win = hs.window.focusedWindow()
   if not win then
      log.w("no focused window")
      return
   end

   local id = win:id()
   local cur = win:frame()
   local s = state[id]

   -- window was moved/resized by something else since we last placed
   -- it: forget the stale original and treat this as a fresh start
   if s and not isNear(cur, s.target) then
      log.df("window %d moved externally; discarding saved frame", id)
      state[id] = nil
      s = nil
   end

   if s and s.key == key then
      log.f("restore window %d to %s", id, s.original)
      win:setFrame(s.original)
      state[id] = nil
      return
   end

   local q = QUADRANTS[key]
   local target = quadrantFrame(win:screen():frame(), q)
   state[id] = {
      original = s and s.original or cur,
      key = key,
      target = target,
   }
   log.f("move window %d to %s %s", id, q.name, target)
   win:setFrame(target)
end

for key, _ in pairs(QUADRANTS) do
   hs.hotkey.bind(hyper, key, function() toggleQuadrant(key) end)
end

