peripheral.find("modem", rednet.open)

while turtle.down() do end

local ok, block = turtle.inspectDown()
if block.name ~= "minecraft:chest" then
    turtle.back()
end

local tree_count, logs_count = 0, 0
local function broadcast_changes()
    rednet.broadcast({ trees = tree_count, logs = logs_count }, "squid/tree-farm")
end

local slots = {
    "minecraft:birch_sapling",
    "minecraft:bone_meal",
    "minecraft:charcoal",
}

while true do
    -- Restock items. First try to pull some items from the chest
    turtle.select(1)
    for i = 1, #slots do turtle.suckDown() end

    -- And now
    local actual_slots, in_slot = {}, {}
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item then
            actual_slots[i] = item and item.name
            in_slot[item.name] = in_slot[item.name] or i
        end
    end

    -- if actual_slots[16] then
    --     turtle.select(16)
    --     turtle.drop()
    -- end

    -- for slot = 1, #slots do
    --     if actual_slots[i] ~=
    -- end

    -- And drop items into the chest
    for i = 4, 16 do
        local count = turtle.getItemCount(i)
        if count > 0 then turtle.select(i) turtle.dropDown(count) end
    end

    if turtle.getFuelLimit() - turtle.getFuelLevel() >= 1000 then
        turtle.select(3)
        turtle.refuel(turtle.getItemCount(3) - 1)
    end

    while true do
        local ok, block = turtle.inspect()
        if not ok then
            turtle.select(1)
            turtle.place()

            sleep(35)
        elseif block.name ~= "minecraft:birch_log" then
            turtle.select(2)
            turtle.place()
        else
            break
        end
    end

    -- Dig
    turtle.dig()
    turtle.forward()
    while true do
        local ok, block = turtle.inspectUp()
        if not ok or block.name ~= "minecraft:birch_log" then
            break
        end

        turtle.digUp()
        logs_count = logs_count + 1
        broadcast_changes()

        turtle.up()
    end
        turtle.digUp() do turtle.up() end

    -- And return to current position
    while turtle.down() do end
    turtle.back()

    tree_count = tree_count + 1
    broadcast_changes()
end
