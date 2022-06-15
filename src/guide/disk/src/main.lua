if pocket then os.pullEvent = os.pullEventRaw end
os.setComputerLabel("A Guide to CC: Restitched")

local map_data = require "map_data"
local info_text = require "info_text"
local Map = require "map"
local InfoBox = require "info_box"

local map = Map()
local info_box = InfoBox()

-- Set up the terminal
local redirect = term.native()
local width, height = redirect.getSize()
term.redirect(redirect)

-- Main map
for i = 1, 16 do
    redirect.setPaletteColour(2 ^ (i - 1), map_data.palette[i])
end

local current_zone, in_help = nil, false

parallel.waitForAll(function()
    local modem = peripheral.find("modem")
    if modem then modem.open(gps.CHANNEL_GPS) end

    while true do
        local time = os.clock()
        local x, y, z = gps.locate(0.2)

        if not pocket then x = 0 z = 0 end

        if x then
            map:set_world_position(x, z)

            for _, zone in pairs(info_text.zones) do
                local inside = (
                    zone.min_x <= x and x <= zone.max_x and
                    zone.min_z <= z and z <= zone.max_z)
                if inside and current_zone ~= zone then
                    current_zone = zone
                    info_box:open(zone.text)
                elseif not inside and current_zone == zone then
                    -- TODO: Don't close when help menu is open.
                    current_zone = nil
                    info_box:close()
                end
            end
        end

        local to_sleep = 0.2 - (os.clock() - time)
        if to_sleep > 0 then sleep(to_sleep) end
    end
end, function()
    local framebuffer = window.create(redirect, 1, 1, width, height, false)

    while true do
        local changed = false
        if (map.dirty or (info_box.dirty and not info_box.target_open)) and info_box.size < 1 then
            map:draw(framebuffer)
            info_box.dirty = true
            changed = true
        end
        if info_box.dirty then
            info_box:draw(framebuffer)
            changed = true
        end
        if changed then framebuffer.setVisible(true) framebuffer.setVisible(false) end

        local event = table.pack(os.pullEvent())
        map:handle_event(not info_box.current_open, table.unpack(event, 1, event.n))
        info_box:handle_event(info_box.current_open, table.unpack(event, 1, event.n))

        if event[1] == "char" and event[2] == "?" then
            info_box:open(info_text.help)
        end
    end
end)
