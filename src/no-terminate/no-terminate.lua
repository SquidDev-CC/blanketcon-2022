local args = table.pack(...)
local display = true

if args[1] == "--silent" then
    display = false
    table.remove(args, 1)
end

while true do
    local co = coroutine.create(shell.execute)

    local ok, result = coroutine.resume(co, table.unpack(args))

    while coroutine.status(co) ~= "dead" do
        local event = table.pack(os.pullEventRaw(result))
        if event[1] == "terminate" then
            if display then printError("No Terminatey!") end

        elseif result == nil or event[1] == result then
            ok, result = coroutine.resume(co, table.unpack(event, 1, event.n))
        end
    end

    if not ok then printError(result) end

    print("Program finished (possibly crashed). Re-running in 10s.")

    local timeout = os.startTimer(5)
    repeat local _, id = os.pullEventRaw("timer") until id == timeout
end
