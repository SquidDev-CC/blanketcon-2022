local map_data = require "map_data"
local buffer = require "buffer"

local t_width, t_height = term.getSize()
local width, height = t_width * 2, t_height * 3

local start_x, start_y = -576, -320

local function clamp(v, min, max)
    if v < min then return min end
    if v > max then return max end
    return v
end

local Map = {}
Map.__index = Map

local function clamp_offsets(x, y, scale)
    local map = map_data.map[scale]
    return clamp(x, 0, #map[1] - width), clamp(y, 0, #map - height)
end

local function set_position(self, x, y)
    local ox, oy = clamp_offsets(x, y, self.scale)
    if ox ~= self.offset_x or oy ~= self.offset_y then
        self.dirty = true
        self.offset_x, self.offset_y = ox, oy
    end
end

local function move(self, x, y)
    self.following = false
    return set_position(self, self.offset_x + x * 2, self.offset_y + y * 3)
end

local function create()
    return setmetatable({
        offset_x = math.floor(#map_data.map[1] / 2),
        offset_y = math.floor(#map_data.map[1][1] / 2),
        scale = 1,

        last_mouse_x = false,
        last_mouse_y = false,

        buffer = buffer.create(width, height),
        dirty = true,
        following = true,
    }, Map)
end

function Map:set_world_position(x, z)
    if not self.following then return end

    local scale = map_data.map[self.scale].scale
    set_position(
        self,
        math.floor((x - start_x) / (2 * scale) - (width / 2)),
        math.floor((z - start_y) / (2 * scale) - (height / 2))
    )
end

function Map:draw(term)
    local b = self.buffer
    local x0, y0, map = self.offset_x, self.offset_y, map_data.map[self.scale]

    if self.dirty then
        self.dirty = false
        for y = 1, height do
            local row = map[y0 + y]
            for x = 1, width do
                local offset = x0 + x
                buffer.point(b, x - 1, y - 1, row:sub(offset, offset))
            end
        end
    end

    buffer.draw(b, term, 1, 1)

    term.setTextColour(colours.white)
    term.setBackgroundColour(colours.black)

    if self.scale == 1 then
        for _, d in pairs(map_data.decorations) do
            local x, y, label = d[1], d[2], d[3]
            if x + #label * 3 >= x0 and x < x0 + width and y >= y0 and y < y0 + height then
                term.setCursorPos(
                    math.floor((x - x0) / 2) + 1,
                    math.floor((y - y0) / 3) + 1
                )
                term.write(label)
            end
        end
    end

    term.setCursorPos(1, t_height)
    local line = "Press ? for help"
    local _, _, bg = term.getLine(t_height)
    term.blit(line, ("0"):rep(#line), bg:sub(1, #line))
end


local function zoom(self, change, x, y)
    local cur_scale = map_data.map[self.scale].scale
    local cx, cy = (self.offset_x + x) * cur_scale, (self.offset_y + y) * cur_scale

    -- Find the new scale
    local new_scale_idx = self.scale + change
    if new_scale_idx < 1 or new_scale_idx > #map_data.map then return end

    local new_scale = map_data.map[new_scale_idx].scale
    self.scale = new_scale_idx

    self.offset_x, self.offset_y = clamp_offsets(
        math.floor(cx / new_scale - x),
        math.floor(cy / new_scale - y),
        new_scale_idx
    )
    self.dirty = true
end

function Map:handle_event(focused, event_name, ...)
    if not focused then return end

    if event_name == "mouse_click" then
        local _, x, y = ...
        self.last_mouse_x, self.last_mouse_y = x, y
    elseif event_name == "mouse_drag" then
        local _, x, y = ...
        move(self, self.last_mouse_x - x, self.last_mouse_y - y)
        self.last_mouse_x, self.last_mouse_y = x, y
    elseif event_name == "mouse_scroll" then
        local dir, x, y = ...
        if dir == 0 then return end

        local dir = dir > 0 and 1 or -1
        if self.following then
            zoom(self, dir, width / 2, height / 2)
        else
            zoom(self, dir, (x - 1) * 2, (y - 1) * 3)
        end
    elseif event_name == "key" then
        local key = ...
        if key == keys.left or key == keys.a or key == keys.h then
            move(self, -1, 0)
        elseif key == keys.right or key == keys.d or key == keys.l then
            move(self, 1, 0)
        elseif key == keys.up or key == keys.w or key == keys.k then
            move(self, 0, -1)
        elseif key == keys.down or key == keys.s or key == keys.j then
            move(self, 0, 1)
        elseif key == keys.equals or key == keys.numPadPlus then
            zoom(self, -1, width / 2, height / 2)
        elseif key == keys.minus or key == keys.numPadSubtract then
            zoom(self, 1, width / 2, height / 2)
        elseif key == keys.space then
            self.following = true
        end
    end
end

return create
