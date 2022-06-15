local width, height = term.getSize()
local empty_text, empty_fg, empty_bg = (" "):rep(width), ("f"):rep(width), ("0"):rep(width)
local header_fg, header_bg = empty_bg, ("d"):rep(width)
local step = 1 / 4

local function pad(line, replace)
    line = line:sub(1, width)
    if #line < width then line = line .. replace:rep(width - #line) end
    return line
end

local InfoBox = {}
InfoBox.__index = InfoBox

local function create()
    return setmetatable({
        current_open = false,
        target_open = false,

        size = 0,
        timer = false,
        text = {},
        offset = 0,

        dirty = false,
    }, InfoBox)
end

function InfoBox:draw(term)
    self.dirty = false

    local size = self.size

    if size == 0 then
        return
    elseif size < 1 then
        local box_width, box_height = math.ceil(width * size), math.ceil(height * size)
        local start_x = math.floor((width - box_width) / 2)
        local start_y = math.floor((height - box_height) / 2)

        local text, bg = (" "):rep(box_width), ("0"):rep(box_width)
        for y = 1, box_height do
            term.setCursorPos(start_x + 1, start_y + y)
            term.blit(text, bg, bg)
        end
    else
        for y = 1, height - 1 do
            term.setCursorPos(1, y)
            local line = self.text[y + self.offset]
            if line then term.blit(line[1], line[2], line[3])
            else term.blit(empty_text, empty_bg, empty_bg) end
        end

        term.setCursorPos(1, height)

        local max_offset = #self.text - (height - 1)
        if self.offset >= max_offset then
            term.blit(pad("Press Backspace to close", " "), empty_fg, empty_bg)
        else
            term.blit(pad("Press \25 to read more", " "), empty_fg, empty_bg)
        end
    end
end

local function change_offset(self, change)
    local new_offset = self.offset + change

    local max_offset = #self.text - (height - 3)
    if new_offset > max_offset then new_offset = max_offset end

    if new_offset < 0 then new_offset = 0 end

    if self.offset ~= new_offset then
        self.offset = new_offset
        self.dirty = true
    end
end

function InfoBox:handle_event(focused, event, ...)
    if event == "timer" and ... == self.timer then
        if self.size == (self.target_open and 1 or 0) then
            self.timer = false
            return
        end

        if self.target_open then
            self.size = self.size + step
        else
            self.size = self.size - step
        end

        assert(self.size >= 0 and self.size <= 1)

        if self.size == (self.target_open and 1 or 0) then
            self.timer = false
            self.current_open = self.target_open
        else
            self.timer = os.startTimer(0.05)
        end

        self.dirty = true
    elseif focused and event == "key" then
        local key = ...
        if key == keys.backspace then
            self:close()
        elseif key == keys.up or key == keys.w or key == keys.k then
            change_offset(self, -1)
        elseif key == keys.down or key == keys.s or key == keys.j then
            change_offset(self, 1)
        elseif key == keys.pageDown then
            change_offset(self, height - 2)
        elseif key == keys.pageUp then
            change_offset(self, -(height - 2))
        end
    elseif focused and event == "mouse_scroll" then
        local dir = ...
        change_offset(self, dir)
    end
end

local function set_open(self, open)
    self.target_open = open
    if not self.timer then self.timer = os.startTimer(0.05) end
end

function InfoBox:open(text)
    local lines = {}
    for line in text:gmatch("([^\n]*)\n?") do
        local header = line:match("^# +(.*)$")
        if header then
            lines[#lines + 1] = { pad(header, " "), header_fg, header_bg }
            lines[#lines + 1] = { ("\131"):rep(width), header_bg, header_fg }
        else
            lines[#lines + 1] = { pad(line, " "), empty_fg, empty_bg }
        end
    end
    self.text = lines
    self.offset = 0

    self.dirty = true
    if not self.target_open then
        set_open(self, true)
    end
end

function InfoBox:close()
    if self.target_open then set_open(self, false) end
end

return create
