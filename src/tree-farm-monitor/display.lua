local expect = require"cc.expect"
local expect, field = expect.expect, expect.field

--- Render text with some basic properties set (colour, position).
local function text(options)
    expect(1, options, "table")

    local term = field(options, "term", "table")
    local y = field(options, "y", "number")
    local text = field(options, "text", "string")

    local fg = field(options, "fg", "number", "nil") or colours.black
    local bg = field(options, "bg", "number", "nil") or colours.white

    term.setCursorPos(2, y)
    term.setTextColour(fg)
    term.setBackgroundColour(bg)
    term.write(text)
end

peripheral.find("modem", rednet.open)

local display = peripheral.find("monitor")
display.setTextScale(1.5)
display.setBackgroundColour(colours.white)

local trees, logs = 0, 0
repeat
    display.clear()
    text { term = display, x = 2, y = 2, text = ("Chopped %d logs"):format(logs) }
    text { term = display, x = 2, y = 4, text = ("Chopped %d trees"):format(trees) }

    local _, message = rednet.receive("squid/tree-farm")
    trees, logs = message.trees, message.logs
until false
