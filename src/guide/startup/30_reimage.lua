if not commands then return end

while true do
    local event, arg = os.pullEvent("computer_command")

    local status = nil
    if not disk.hasData("left") then
        status = "No disk on the left"
    elseif shell.run("/startup/01_vegbox.lua") then
        status = "Reimaged computer"
    else
        status = "Failed to reimage"
    end

    print(status)
    if arg then commands.tell(arg, status) end
end
