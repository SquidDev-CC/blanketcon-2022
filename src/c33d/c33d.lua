local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

local block_lookup = {
    ["minecraft:air"] = " ",
    ["minecraft:dirt"] = "d",
    ["minecraft:grass_block"] = "g",
    ["minecraft:stone"] = "s",
    ["minecraft:water"] = "w",
}

--[[- Scan a portion of the world and convert in into a JSON file, which can
then be read by our server.

We emit blocks as a `List (List String)`, such that when the JSON file is
formatted you get a list of "slices" of the world viewed from above, from lowest
to highest. See world.json for an example.
]]
local function scan(min_x, min_y, min_z, max_x, max_y, max_z)
    expect(1, min_x, "number")
    expect(2, min_y, "number")
    expect(3, min_z, "number")
    expect(4, max_x, "number")
    expect(5, max_y, "number")
    expect(6, max_z, "number")

    min_x, max_x = math.min(min_x, max_x), math.max(min_x, max_x)
    min_y, max_y = math.min(min_y, max_y), math.max(min_y, max_y)
    min_z, max_z = math.min(min_z, max_z), math.max(min_z, max_z)

    local output = {}
    for y0 = min_y, max_y, 5 do
        local height = math.min(max_y, y0 + 5) - y0 + 1
        local width = max_x - min_x + 1
        local depth = max_z - min_z + 1

        local blocks = commands.getBlockInfos(min_x, y0, min_z, max_x, y0 + height - 1, max_z)

        for y = 0, height - 1 do
            local row = {}
            for z = 0, depth - 1 do
                local line = {}
                for x = 0, width - 1 do
                    local block = blocks[1 + x + z * width + y * width * depth]

                    if not block then
                        error(("Out of bounds at %d, %d, %d (idx=%d, len=%d)"):format(x, y, z, 1 + x + z * width + y * width * depth, #blocks))
                    end

                    local char = block_lookup[block.name]
                    if not char then
                        print(string.format("Unknown block %s at %d, %d, %d", block.name, x, y, z))
                        char = " "
                    end

                    line[x + 1] = char
                end

                row[z + 1] = table.concat(line)
            end

            output[(y0 - min_y) + y + 1] = row
        end
    end

    return output
end

--- Set up a terminal redirect with our custom palette.
local function set_palette(monitor)
    expect(1, monitor, "table")

    -- White
    monitor.setPaletteColour(2 ^ 0, 0xf0f0f0)
    -- Green
    monitor.setPaletteColour(2 ^ 1, 0x73b349)
    monitor.setPaletteColour(2 ^ 2, 0x5f9f35)
    monitor.setPaletteColour(2 ^ 3, 0x509026)
    -- Brown
    monitor.setPaletteColour(2 ^ 4, 0x966c4a)
    monitor.setPaletteColour(2 ^ 5, 0x79553a)
    monitor.setPaletteColour(2 ^ 6, 0x593d29)
    -- Blue
    monitor.setPaletteColour(2 ^ 7, 0x3266cc)
    monitor.setPaletteColour(2 ^ 8, 0x4c32cc)
    -- Cornflower Blue
    monitor.setPaletteColour(2 ^ 9, 0x6495ED)
    -- Grey
    monitor.setPaletteColour(2 ^ 10, 0x8f8f8f)
    monitor.setPaletteColour(2 ^ 11, 0x747474)
    monitor.setPaletteColour(2 ^ 12, 0x686868)
end

local function get_str(message, width, y, kind)
    local start = kind * width + y * width * 3
    return message:sub(start + 1, start + width)
end

local function display(args)
    expect(1, args, "table")

    local address = field(args, "address", "string")
    local world = field(args, "world", "table")

    local monitor = field(args, "monitor", "table")
    local monitor_x = field(args, "monitor_x", "number")
    local monitor_y = field(args, "monitor_y", "number")
    local monitor_z = field(args, "monitor_z", "number")

    local selector = field(args, "selector", "string", "nil") or ("x=%d,y=%d,z=%d,dx=%d,dy=%d,dz=%d"):format(
        monitor_x, monitor_y - 3, monitor_z - 16,
        12, 10, 16
    )
    local pos_command = ("data get entity @p[%s,limit=1,gamemode=!spectator] Pos"):format(selector)

    local offset_x = field(args, "offset_x", "number", "nil") or (#world[1][1] - 6) / 2
    local offset_y = field(args, "offset_y", "number", "nil") or 1
    local offset_z = field(args, "offset_z", "number", "nil") or 0

    monitor.setTextScale(0.5)
    set_palette(monitor)
    monitor.setBackgroundColour(colours.black)
    monitor.clear()

    local width, height = monitor.getSize()
    width, height = width - 2, height - 2

    local initial_payload = textutils.serializeJSON({
        world = world,
        offsetX = offset_x, offsetY = offset_y, offsetZ = offset_z,
    })

    local ws = assert(http.websocket(address))
    ws.send(initial_payload)

    local has_position, player_x, player_y, player_z = false, 0, 0, 0
    local locate_task = nil

    local send_queue = {}

    local running = true
    while running do
        if locate_task == nil then
            locate_task = commands.execAsync(pos_command)
        end

        local event, arg1, arg2, arg3, arg4 = os.pullEventRaw()
        if event == "terminate" then
            running = false

        elseif event == "task_complete" and locate_task and arg1 == locate_task then
            locate_task = nil

            local data = arg4
            if arg2 and arg3 and #data >= 1 then
                local json = data[1]:match("^[^ ]+ has the following entity data: (.+)")
                if not json then print(data[1])
                else
                    local position = textutils.unserialiseJSON(json, { nbt_style = true })

                    has_position = true
                    local new_x = position[1] - monitor_x
                    local new_y = position[2] - monitor_y + 1.625
                    local new_z = position[3] - monitor_z

                    -- Only send a message if the player hasn't moved at all.
                    if ws and math.abs(player_x - new_x) + math.abs(player_y - new_y) + math.abs(player_z - new_z) > 0.05 then
                        player_x, player_y, player_z = new_x, new_y, new_z
                        ws.send(textutils.serializeJSON({ x = player_x, y = player_y, z = player_z }))
                        table.insert(send_queue, os.epoch("utc"))
                    end
                end
            else
                -- TODO: Show some status text here.
                has_position = false
            end

        elseif event == "websocket_message" and arg1 == address then
            local sent = table.remove(send_queue, 1)
            -- if sent then
            --     print(("Took %.2fs to render (%d left in queue)"):format((os.epoch("utc") - sent) * 1e-3, #send_queue))
            -- end

            local message = arg2
            for y = 0, height - 1 do
                monitor.setCursorPos(2, y + 2)
                monitor.blit(get_str(message, width, y, 0), get_str(message, width, y, 1), get_str(message, width, y, 2))
            end

        elseif event == "websocket_closed" and arg1 == address then
            locate_task = nil

            printError("Connection lost")
            repeat
                ws, err = assert(http.websocket(address))
                if not ws then
                    printError(ws)
                    sleep(5)
                end
            until ws

            print("Reconnected")
            ws.send(initial_payload)
            send_queue = {}
        end
    end

    if ws then ws.close() end
    error("Terminated", 0)
end


-- Attempt to guess when we're being required, and behave as a library instead.
-- No, I don't recommend this approach.
if select('#', ...) == 1 then
    local caller = debug.getinfo(2)
    if caller and caller.name == "require" and caller.short_src == "require.lua" then
        return {
            scan = scan,
            set_palette = set_palette,
            display = display,
        }
    end
end

local function check_num(name, value)
    if value == nil then return nil end

    local number = tonumber(value)
    if not number then error(("scan: %s is not a number"):format(name), 0) end
    return number
end

if ... == "scan" then
    if select('#', ...) ~= 8 then
        printError("Usage: c33d scan MIN-X MIN-Y MIN-Z MAX-X MAX-Y MAX-Z OUTPUT")
        error()
    end

    local _, min_x, min_y, min_z, max_x, max_y, max_z, filename = ...
    local output = scan(
        check_num("MIN-X", min_x),
        check_num("MIN-Y", min_y),
        check_num("MIN-Z", min_z),
        check_num("MAX-X", max_x),
        check_num("MAX-Y", max_y),
        check_num("MAX-Z", max_z)
    )

    local handle = assert(fs.open(shell.resolve(filename), "w"))
    handle.write(textutils.serialiseJSON(output))
    handle.close()

elseif ... == "draw" then
    if select('#', ...) ~= 7 and select('#', ...) ~= 10 then
        printError("Usage: c33d draw SERVER MONITOR MON-X MON-Y MON-Z WORLD [WORLD-X WORLD-Y WORLD-Z]")
        error()
    end

    local _, address, monitor, mon_x, mon_y, mon_z, world, world_x, world_y, world_z = ...

    local handle = assert(fs.open(shell.resolve(world), "r"))
    local world = textutils.unserialiseJSON(handle.readAll())
    handle.close()

    local monitor_p = peripheral.wrap(monitor)
    if not monitor_p then printError("Cannot find monitor") error() end
    if not peripheral.hasType(monitor_p, "monitor") then printError(monitor .. " is not a monitor") error() end

    display {
        address = address,
        world = world,
        monitor = monitor_p,
        monitor_x = check_num("MON-X", mon_x), monitor_y = check_num("MON-Y", mon_y), monitor_z = check_num("MON-Z", mon_z),

        offset_x = check_num("WORLD-X", world_x),
        offset_y = check_num("WORLD-Y", world_y),
        offset_z = check_num("WORLD-Z", world_z),
    }
else
    -- Unknown command
    printError("Usage:")
    printError("  c33d scan MIN-X MIN-Y MIN-Z MAX-X MAX-Y MAX-Z OUTPUT")
    printError("  c33d draw SERVER MONITOR MON-X MON-Y MON-Z WORLD [WORLD-X WORLD-Y WORLD-Z]")
    error()
end
