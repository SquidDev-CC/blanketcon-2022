local pretty = require "cc.pretty"
local button = require "button"
local questions = require "questions"
local wrap = require "cc.strings".wrap
local loader = require "loader"

local CHANNEL = 16459
local modem = peripheral.find("modem", function(_, x) return x.isWireless() end)
modem.open(CHANNEL)

local function to_json(tbl)
    return ("%q"):format(textutils.serializeJSON(tbl))
end

local function create_display(
    x, y, z,
    display_x, display_y, display_z, side_z,
    t_width, t_height
)
    local current_image = false

    return function(image)
        if image == current_image then return end
        current_image = image

        if not image then
            commands.async.data.modify.block(x, y, z, "Text1", "set", "value", to_json { text = "" })
            return
        end

        commands.async.data.modify.block(x, y, z, "Text1", "set", "value", to_json {
            text = ("!PS:%s"):format(image.url)
        })

        local width, height = image.width, image.height

        local scale = math.min(t_width / width, t_height / height)
        width = scale * width
        height = scale * height

        local dx, dy, dz = display_x - x, display_y - y - height / 2, display_z - z + width * side_z / 2

        commands.async.data.modify.block(x, y, z, "Text4", "set", "value", to_json {
            text = ("%s:%s:%s:%s:%s"):format(width, height, dx, dy, dz)
        })
    end
end

local file = ... or error("slides [ALBUM]", 0)
local images = loader(file)
print(("%s has %d images"):format(file, #images))

local margin = 2/16
local display_image = create_display(
    -67, 72, -192,
    -67.98, 77, -191.5, 1,
    7 - margin * 2, 6 - margin * 2
)

local prev_slide_l = create_display(
    -69, 71, -196,
    -63.5, 74.5, -197.5, -1,
    0.8, 0.8
)

local next_slide_l = create_display(
    -69, 71, -194,
    -63.5, 74.5, -195.5, -1,
    0.8, 0.8
)

local prev_slide_r = create_display(
    -69, 71, -190,
    -63.5, 74.5, -187.5, -1,
    0.8, 0.8
)

local next_slide_r = create_display(
    -69, 71, -189,
    -63.5, 74.5, -185.5, -1,
    0.8, 0.8
)

local image, blank, dirty = 1, false, true
local function go_next() if image < #images then image = image + 1 dirty = true end end
local function go_prev() if image > 1 then image = image - 1 dirty = true end end

local display_monitor = peripheral.wrap("monitor_11")
display_monitor.setTextScale(5)

local display_width = display_monitor.getSize()

local backstage_monitors = {}
for _, monitor in pairs({ "monitor_10", "monitor_12", "monitor_13" }) do
    local backstage_monitor = peripheral.wrap(monitor)
    backstage_monitor.setTextScale(0.5)
    backstage_monitors[monitor] = backstage_monitor
end

local backstage_image = false
local backstage_buttons = {
    next = { x =  2, y = 3, text = "Prev Slide", touch = go_prev },
    prev = { x = 46, y = 3, text = "Next Slide", touch = go_next },
    clear = { x = 24, y = 3, text = "Clear Slide", bg = colours.red, touch = function(self)
        blank = not blank
        dirty = true
    end },
}
local backstage_width = backstage_monitors.monitor_10.getSize()

local function dismiss_q(self)
    self._question.visible = false
    questions.save_questions()
end

local function show_q(self)
    blank = true
    dirty = true

    dismiss_q(self)

    display_monitor.setTextColour(colours.black)
    display_monitor.setBackgroundColour(colours.white)
    display_monitor.clear()

    -- Display the question
    local lines = wrap(self._question.pages, display_width - 2)
    for y, text in pairs(lines) do
        display_monitor.setCursorPos(2, y + 1)
        display_monitor.write(text)
    end
    display_monitor.setCursorPos(2, #lines + 3)
    display_monitor.write(" - " .. self._question.author)
end

local function sync_remote(slide, next_slide)
    modem.transmit(CHANNEL, CHANNEL, {
        action = "set_state",
        blank = blank,
        current_slide = slide.desc or slide.url,
        next_slide = next_slide and (next_slide.desc or next_slide.url) or "",
        questions = questions.questions,
    })
end

local function tick()
    local slide, next_slide, prev_slide = images[image], images[image + 1], images[image - 1]
    if blank then display_image(nil) else display_image(slide) end
    prev_slide_l(prev_slide) prev_slide_r(prev_slide)
    next_slide_l(next_slide) next_slide_r(next_slide)

    if dirty or questions.poll_dirty() then
        dirty = false

        -- Clear all our old buttons
        for k, v in pairs(backstage_buttons) do if v._question then backstage_buttons[k] = nil end end
        backstage_buttons.clear.text = blank and "Show  Slide" or "Clear Slide"
        backstage_buttons.clear.bg = blank and colours.green or colours.red

        for _, backstage_monitor in pairs(backstage_monitors) do
            backstage_monitor.setTextColour(colours.black)
            backstage_monitor.setBackgroundColour(colours.white)
            backstage_monitor.clear()

            local old = term.redirect(backstage_monitor)

            local y, i = 6, 0
            local function start_line() term.setCursorPos(2, y) term.clearLine() y = y + 1 end
            for _, question in pairs(questions.questions) do
                if question.visible then
                    i = i + 1
                    local bg = i % 2 == 0 and colours.lightGrey or colours.white

                    term.setBackgroundColour(bg)
                    start_line()

                    backstage_buttons["q_" .. i] = { x = 55, y = y - 1, text = "\2", bg = colours.green, border = bg, _question = question, touch = show_q }
                    backstage_buttons["r_" .. i] = { x = 55, y = y + 1, text = "X",  bg = colours.red,   border = bg, _question = question, touch = dismiss_q }

                    local wrapped = wrap(question.pages, backstage_width - 4)
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

            term.setCursorPos(1, 1)
            pretty.print(
                pretty.text("Current Slide: ", colours.lightGrey) .. pretty.text(slide.desc or slide.url) ..
                pretty.space_line ..
                pretty.text("   Next Slide: ", colours.lightGrey) .. pretty.text(next_slide and (next_slide.desc or next_slide.url) or "")
            )
            term.redirect(old)

            button.draw(backstage_buttons, backstage_monitor)
        end

        if not blank then
            display_monitor.setBackgroundColour(colours.black)
            display_monitor.clear()
        end

        sync_remote(slide, next_slide)
    end

    local event, arg1, arg2, arg3, arg4, arg5 = os.pullEvent()
    if event == "redstone" then
        local mask = redstone.getBundledInput("back")
        if colours.test(mask, colours.white) or colours.test(mask, colours.magenta) then go_next()
        elseif colours.test(mask, colours.lightBlue) or colours.test(mask, colours.orange) then go_prev()
        elseif colours.test(mask, colours.yellow) or colours.test(mask, colours.lime) then
            for _, command in pairs(slide.commands) do
                print("Running " .. command)
                commands.execAsync(command)
            end
        end
    elseif event == "key" and arg1 == keys.right then go_next()
    elseif event == "key" and arg1 == keys.left then go_prev()
    elseif event == "key" and arg1 == keys.backspace then return true
    elseif event == "monitor_touch" and backstage_monitors[arg1] then
        button.touch(backstage_buttons, arg2, arg3)
    elseif event == "modem_message" and arg2 == CHANNEL and arg5 <= 64 then
        local msg = arg4

        print("Processing " .. pretty.pretty(msg))
        if msg.action == "next_slide" then go_next()
        elseif msg.action == "prev_slide" then go_prev()
        elseif msg.action == "set_blank" then dirty = true blank = msg.blank
        elseif msg.action == "sync_remote" then sync_remote(slide, next_slide)
        elseif msg.action == "show_q" then show_q({ _question = questions.questions[msg.q] })
        elseif msg.action == "dismiss_q" then dismiss_q({ _question = questions.questions[msg.q] })
        end
    elseif event == "modem_message" then print(arg1, arg2, arg3, arg4, arg5)
    elseif event == "task_complete" and arg3 == false then
        -- pretty.print("Task failed " .. pretty.pretty({ ok = arg3, data = arg4 }))
    end
end

parallel.waitForAny(function() repeat until tick() end, questions.run)
