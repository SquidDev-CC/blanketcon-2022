local pretty = require "cc.pretty"
local button = require "button"
local wrap = require "cc.strings".wrap

local CHANNEL = 16459
local modem = peripheral.find("modem")
modem.open(CHANNEL)
modem.transmit(CHANNEL, CHANNEL, { action = "sync_remote" })

local current_slide, next_slide, blank, questions = "", "", false, {}

local function go_prev() modem.transmit(CHANNEL, CHANNEL, { action = "prev_slide" }) end
local function go_next() modem.transmit(CHANNEL, CHANNEL, { action = "next_slide" }) end
local function set_blank(blank) modem.transmit(CHANNEL, CHANNEL, { action = "set_blank", blank = blank }) end
local function toggle_blank() set_blank(not blank) end

local function show_q(self) modem.transmit(CHANNEL, CHANNEL, { action = "show_q", q = self._question }) end
local function dismiss_q(self) modem.transmit(CHANNEL, CHANNEL, { action = "dismiss_q", q = self._question }) end

local buttons = {
    prev = { x =  2, y = 18, text = "Prev", touch = go_prev },
    next = { x = 19, y = 18, text = "Next", touch = go_next },
    clear = { x = 10, y = 18, text = "Clear", bg = colours.red, touch = toggle_blank },
}

local dirty = true

while true do
    if dirty then
        dirty = false

        term.setTextColour(colours.black)
        term.setBackgroundColour(colours.white)
        term.clear()

        term.setCursorPos(1, 1)
        pretty.print(
            pretty.text("Current Slide: ", colours.lightGrey) .. pretty.text(current_slide) ..
            pretty.space_line ..
            pretty.text("   Next Slide: ", colours.lightGrey) .. pretty.text(next_slide)
        )

        -- Clear all our old buttons
        for k, v in pairs(buttons) do if v._question then buttons[k] = nil end end

        local y, i = select(2, term.getCursorPos()), 0
        local function start_line() term.setCursorPos(2, y) term.clearLine() y = y + 1 end
        for idx, question in pairs(questions) do
            if question.visible then
                i = i + 1
                local bg = i % 2 == 0 and colours.lightGrey or colours.white

                local wrapped = wrap(question.pages, 26 - 4)
                if y + #wrapped >= 18 and i > 1 then break end

                term.setBackgroundColour(bg)
                start_line()

                buttons["q_" .. i] = { x = 24, y = y - 1, text = "\2", bg = colours.green, border = bg, _question = idx, touch = show_q }
                buttons["r_" .. i] = { x = 24, y = y + 1, text = "X",  bg = colours.red,   border = bg, _question = idx, touch = dismiss_q }

                for i = 1, math.min(6, #wrapped) do -- Trim too long questions. They're probably fine?
                    start_line()
                    term.write(wrapped[i])
                end

                start_line()
                term.write(" - From " .. question.author)

                start_line()
                if #wrapped <= 1 then start_line() end
            end
        end
        term.setBackgroundColour(colours.white)

        button.draw(buttons, term)
    end

    local event = table.pack(os.pullEvent())
    if event[1] == "modem_message" and event[3] == CHANNEL and event[6] and event[6] <= 64 then
        local msg = event[5]
        if msg.action == "set_state" then
            dirty = true
            current_slide = msg.current_slide
            next_slide = msg.next_slide
            blank = msg.blank
            questions = msg.questions

            buttons.clear.text = blank and "Show " or "Clear"
            buttons.clear.bg = blank and colours.green or colours.red
        end

    elseif event[1] == "key" and event[2] == keys.right then go_next()
    elseif event[1] == "key" and event[2] == keys.left then go_prev()
    elseif event[1] == "key" and event[2] == keys.b then toggle_blank()

    elseif event[1] == "mouse_click" then
        button.touch(buttons, event[3], event[4])
    end
end
