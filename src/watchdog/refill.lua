local layers = {}

local width, height, depth = 8, 30, 8
for i = 1, width * height * depth do
    layers[i] = "minecraft:stone"
end

local sx, sy, sz = -17, 40, 336

local function to_offset(x, y, z)
    return 1 + x + y * width + z * width * height
end

for i = 1, 30 do
    local x = math.random(0, width - 1)
    local y = math.random(0, height - 1)
    local z = math.random(0, depth - 1)

    local weights = { { "minecraft:coal_ore", 3 } }
    if y < 10 then weights[#weights + 1] = {"minecraft:diamond_ore", 1} end
    if y < 20 then weights[#weights + 1] = {"minecraft:iron_ore", 2 } end
    local total_weight = 0
    for _, w in pairs(weights) do total_weight = total_weight + w[2] end

    local ore = nil
    local chance = math.random(0, total_weight - 1)
    for _, w in pairs(weights) do
        if chance <= w[2] then
            ore = w[1]
            break
        end

        chance = chance - w[2]
    end

    assert(ore)

    layers[to_offset(x, y, z)] = ore
    while math.random() <= 0.7 do
        local x, y, z = x + math.random(-1, 1), y + math.random(-1, 1), z + math.random(-1, 1)
        if x >= 0 and x < width and y >= 0 and y < height and z >= 0 and z < depth then
            layers[to_offset(x, y, z)] = ore
        end
    end

end

for y = 0, height - 1 do
    local tasks = {}

    for x = 0, width - 1 do for z = 0, depth - 1 do
        local id = commands.async.setblock(sx + x, sy + y, sz + z, layers[to_offset(x, y, z)])
        tasks[id] = true
    end end

    while next(tasks) do
        local _, id, ok, err = os.pullEvent("task_complete")
        tasks[id] = nil

        if not ok then printError(err) end
    end

    sleep(0)
end
