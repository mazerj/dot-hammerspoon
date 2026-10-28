
-- binds hyper-1..4 to move/resize the focused window into a screen
-- quadrant (UL, UR, LL, LR) and hyper-9/0 to the left/right half.
-- Pressing the same key again restores the window's frame from before
-- the first move. Switching between regions keeps the original frame
-- for the eventual restore.

local log = hs.logger.new('quadrants', 'info')

-- fraction of each region the window occupies (centered in it)
local SCALE = 0.95

-- tolerance (px) when checking whether a window is still where we put
-- it; generous because some apps (terminals) snap to char cell sizes
local EPSILON = 30

-- region offsets and spans in units of half-screen
local REGIONS = {
   ["1"] = { name = "upper-left",  col = 0, row = 0, cols = 1, rows = 1 },
   ["2"] = { name = "upper-right", col = 1, row = 0, cols = 1, rows = 1 },
   ["3"] = { name = "lower-left",  col = 0, row = 1, cols = 1, rows = 1 },
   ["4"] = { name = "lower-right", col = 1, row = 1, cols = 1, rows = 1 },
   ["9"] = { name = "left-half",   col = 0, row = 0, cols = 1, rows = 2 },
   ["0"] = { name = "right-half",  col = 1, row = 0, cols = 1, rows = 2 },
}

-- per-window state, keyed by window id:
--   { original = <frame before first region move>,
--     key      = <region key last applied>,
--     target   = <frame last requested> }
local state = {}

local function regionFrame(screenFrame, r)
   local hw = screenFrame.w / 2
   local hh = screenFrame.h / 2
   local rw = hw * r.cols
   local rh = hh * r.rows
   local w = rw * SCALE
   local h = rh * SCALE
   return hs.geometry.rect(
      screenFrame.x + r.col * hw + (rw - w) / 2,
      screenFrame.y + r.row * hh + (rh - h) / 2,
      w, h)
end

local function isNear(a, b)
   return math.abs(a.x - b.x) < EPSILON and
      math.abs(a.y - b.y) < EPSILON and
      math.abs(a.w - b.w) < EPSILON and
      math.abs(a.h - b.h) < EPSILON
end

local function toggleRegion(key)
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

   local r = REGIONS[key]
   local target = regionFrame(win:screen():frame(), r)
   state[id] = {
      original = s and s.original or cur,
      key = key,
      target = target,
   }
   log.f("move window %d to %s %s", id, r.name, target)
   win:setFrame(target)
end

for key, _ in pairs(REGIONS) do
   hs.hotkey.bind(hyper, key, function() toggleRegion(key) end)
end

