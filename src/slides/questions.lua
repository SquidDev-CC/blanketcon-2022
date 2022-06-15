local x, y, z = -65, 70, -196

local questions, dirty = {}, false

local h = fs.open("/questions.json", "r")
if h then
    questions = textutils.unserialiseJSON(h.readAll())
    h.close()
end

print(("Read %d questions"):format(#questions))

local function save_questions()
    local h = fs.open("/questions.json", "w")
    h.write(textutils.serialiseJSON(questions))
    h.close()
    dirty = true
end

local function add_question(pages, author)
    local pages = table.concat(pages, "\n"):gsub("\n[\n ]*", "\n")
    questions[#questions + 1] = {
        author = author, pages = pages, visible = true,
    }
    save_questions()
end

local function poll_dirty()
    if not dirty then return false end
    dirty = false
    return true
end

local function run()
    while true do
        local info = commands.getBlockInfo(x, y, z)
        for slot, item in pairs(info.nbt.Items) do
            if item.id == "minecraft:writable_book" and item.tag and item.tag.pages then
                local pages = {}
                for i = 0, #item.tag.pages do pages[i + 1] = item.tag.pages[i] end
                add_question(pages, "Anonymous")
            elseif item.id == "minecraft:written_book" and item.tag and item.tag.pages then
                local pages = {}
                for i = 0, #item.tag.pages do
                    local page = item.tag.pages[i]
                    pages[i + 1] = textutils.unserialiseJSON(page).text
                end

                add_question(pages, item.tag.author)
            end

            commands.async.data.remove.block(x, y, z, "Items[" .. slot .. "]")
        end

        sleep(1)
    end
end

return {
    run = run,
    poll_dirty = poll_dirty,
    questions = questions,
    save_questions = save_questions,
}
