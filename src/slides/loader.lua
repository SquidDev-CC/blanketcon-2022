local function format_image(image)
    local description = image.description
    local commands = {}
    if description ~= nil then
        local actual_description = nil
        for line in description:gmatch("[^\n]+") do
            if line:sub(1, 1) == "/" then
                commands[#commands + 1] = line
            elseif line ~= "" and actual_description == nil then
                actual_description = line
            end
        end

        description = actual_description
    end

    return {
        url = image.link, width = image.width, height = image.height,
        desc = description, commands = commands,
    }
end

local function load_album(album)
    local response = assert(http.get('https://api.imgur.com/3/album/' .. album .. '/images', {
        Authorization = "Client-ID REDACTED"
    }))

    local contents = textutils.unserialiseJSON(response.readAll())
    response.close()

    local images = {}
    for i, image in pairs(contents.data) do images[i] = format_image(image) end
    return images
end


return function(name)
    local album = name:match("^https://imgur.com/a/(.+)")
    if album then return load_album(album) end

    if name:sub(1, 8) == "https://" or name:sub(1, 7) == "http://" then
        local handle = assert(http.get(name))
        local result = textutils.unserialiseJSON(handle.readAll())
        handle.close()
        return result
    else
        local handle = assert(fs.open("slides/" .. name .. ".json", "r"))
        local result = textutils.unserialiseJSON(handle.readAll())
        handle.close()
        return result
    end
end
