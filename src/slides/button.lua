local function write_with(term, text, fg, bg)
    term.setBackgroundColour(bg)
    term.setTextColour(fg)
    term.write(text)
end

local function draw_border_cell(term, back, border, char, invert)
    if invert then
        write_with(term, char, back, border)
    else
        write_with(term, char, border, back)
    end
end

local function draw_border(term, back, border, x, y, width, height)
    -- Write border
    term.setCursorPos(x, y)
    draw_border_cell(term, back, border, "\159", true)
    draw_border_cell(term, back, border, ("\143"):rep(width - 2), true)
    draw_border_cell(term, back, border, "\144", false)

    for dy = 1, height - 1 do
        term.setCursorPos(x, dy + y)
        draw_border_cell(term, back, border, "\149", true)

        term.setBackgroundColour(back)
        term.write((" "):rep(width - 2))

        draw_border_cell(term, back, border, "\149", false)
    end

    term.setCursorPos(x, height + y - 1)
    draw_border_cell(term, back, border, "\130", false)
    draw_border_cell(term, back, border, ("\131"):rep(width - 2), false)
    draw_border_cell(term, back, border, "\129", false)
end

local function draw(buttons, term)
    for _, self in pairs(buttons) do
        draw_border(term, self.border or colours.white, self.bg or colours.blue, self.x, self.y, #self.text + 2, 3)
        term.setCursorPos(self.x + 1, self.y + 1)
        write_with(term, self.text, colours.white, self.bg or colours.blue)
    end
end

local function touch(buttons, x, y)
    for _, self in pairs(buttons) do
        if x >= self.x - 1 and x <= self.x + #self.text + 2 and y >= self.y and y <= self.y + 2 then
            self:touch()
        end
    end
end

return { draw = draw, touch = touch }
