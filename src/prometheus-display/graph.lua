local buffer = require "buffer"
local bigfont = require "bigfont"

local base_url = 'https://squiddev.cc/blanketcon/prom'

local function request_now(query)
    local url = ("%s/query?query=%s"):format(base_url, textutils.urlEncode(query))
    local resp, err = http.get(url)
    if not resp then printError(err) return nil end

    local contents = textutils.unserialiseJSON(resp.readAll())
    resp.close()

    if #contents.data.result == 0 then return nil end

    return tonumber(contents.data.result[1].value[2])
end

local function request_until(query, range, step)
    local finish = math.floor(os.epoch("utc") * 1e-3)

    local url = ("%s/query_range?query=%s&start=%d&end=%d&step=%d"):format(
        base_url, textutils.urlEncode(query),
        finish - range, finish, step
    )
    local resp, err = http.get(url)
    if not resp then printError("Error handling " .. url .. ": " .. err) return nil end

    local contents = textutils.unserialiseJSON(resp.readAll())
    resp.close()

    local out = {}
    for i, values in pairs(contents.data.result[1].values) do
        out[i] = tonumber(values[2])
    end

    return out
end

local term = peripheral.find("monitor") or term.current()
if term.setTextScale then term.setTextScale(0.5) end
term.setBackgroundColour(colours.white)
term.setTextColour(colours.black)
term.clear()

local width, height = term.getSize()

local function plot_stat(x, y, label, format, value)
    local value = value and string.format(format, value) or "?"

    local width_val, width_lab = #value * 9, #label * 3

    local offset_val, offset_lab = 0, 0
    if width_val > width_lab then
        offset_lab = math.floor((width_val - width_lab) / 2)
    else
        offset_val = math.floor((width_lab - width_val) / 2)
    end

    bigfont.writeOn(term, 2, value, x + offset_val, y)
    bigfont.writeOn(term, 1, label, x + offset_lab, y + 10)
    term.setCursorPos(x, y)
end

local mspt_width, mspt_height = 122, 33
local mspt_buffer = buffer.create(mspt_width + 4, mspt_height + 6)

local running = true
while running do
    local tick_time, players, computers_on, memory
    parallel.waitForAll(table.unpack {
        function() tick_time = request_until('minecraft_average_tick_time_s*1e9', 15 * 60, 15) end,
        function() players = request_now('minecraft_total_players_count') end,
        function() computers_on = request_now('computercraft_computers_on') end,
        function() memory = request_now('jvm_memory_bytes_used{job="blanketcon"} / (1024 ^ 3)') end,
    })

    term.clear()

    ----------------------------------------------------------------------------
    -- ms/tick graph
    ----------------------------------------------------------------------------

    -- Compute the min/max value
    local min_tick_time, max_tick_time = math.huge, 0
    for x = 1, #tick_time do
        max_tick_time = math.max(max_tick_time, tick_time[x])
        min_tick_time = math.min(min_tick_time, tick_time[x])
    end
    min_tick_time = min_tick_time * 0.8
    max_tick_time = max_tick_time / 0.8

    local function to_y(value)
        local v = (value - min_tick_time) / (max_tick_time - min_tick_time) * (mspt_height + 1)
        return math.floor(mspt_height - v) + 3
    end

    -- Plot the graph
    buffer.clear(mspt_buffer)
    local border = "1"
    for x = 0, mspt_width  + 3 do buffer.point(mspt_buffer, x, 0, border); buffer.point(mspt_buffer, x, mspt_height + 5, border) end
    for y = 0, mspt_height + 5 do buffer.point(mspt_buffer, 0, y, border); buffer.point(mspt_buffer, mspt_width + 3, y, border)  end
    buffer.point(mspt_buffer, 1, to_y(min_tick_time), border)
    buffer.point(mspt_buffer, 1, to_y(max_tick_time), border)

    for x = 1, #tick_time do
        buffer.point(mspt_buffer, (x - 1) * 2 + 2, to_y(tick_time[x]), "a")
    end

    local mspt_y = height - mspt_height / 3 - 2
    buffer.draw(mspt_buffer, term, 2, mspt_y)
    term.setCursorPos(3, mspt_y + 1)
    term.write(("%.3f ms/t"):format(max_tick_time))
    term.setCursorPos(3, mspt_y + mspt_height / 3)
    term.write(("%.3f ms/t"):format(min_tick_time))

    ----------------------------------------------------------------------------
    -- TPS
    ----------------------------------------------------------------------------
    term.setTextColour(colours.green)
    local tps = tick_time[1] and math.min(20, 1000 / tick_time[#tick_time])
    plot_stat(width - 34, mspt_y, "Current TPS", "%.1f", tps)

    ----------------------------------------------------------------------------
    -- Player count
    ----------------------------------------------------------------------------
    term.setTextColour(colours.blue)
    plot_stat(2, 10, "Players", "%d", players)

    ----------------------------------------------------------------------------
    -- Computer count
    ----------------------------------------------------------------------------
    term.setTextColour(colours.red)
    plot_stat(30, 10, "Computers", "%d", computers_on)

    ----------------------------------------------------------------------------
    -- Memory
    ----------------------------------------------------------------------------
    term.setTextColour(colours.blue)
    plot_stat(width - 34, 10, "Memory (GB)", "%.1f", memory)

    ----------------------------------------------------------------------------
    -- Title
    ----------------------------------------------------------------------------
    term.setTextColour(colours.black)
    bigfont.writeOn(term, 1, "Server Statistics", math.floor((width - 17 * 3) / 2), 2)

    local text = "Powered by CC: Prometheus, a Prometheus exporter for CC and MC"
    term.setCursorPos(math.floor((width - #text) / 2), 5)
    term.write(text)

    -- Wait for another scrape and display the results
    local timer = os.startTimer(15)
    while true do
        local event, arg = os.pullEvent()
        if event == "timer" and arg == timer then break
        elseif event == "key" and arg == keys.enter then running = false break
        end
    end
end

term.setBackgroundColour(colours.black)
term.setTextColour(colours.white)
term.setCursorPos(1, 1)
term.clear()
