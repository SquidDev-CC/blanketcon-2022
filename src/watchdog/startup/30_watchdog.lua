local function check_command(ok, result)
    local display = ok and print or printError
        for _, line in pairs(result) do display(line) end
end

parallel.waitForAll(function()
    while true do
        -- Kill any quarry experience orbs
        check_command(commands.kill("@e[type=minecraft:experience_orb,x=-17,y=40,z=336,dx=8,dy=30,dz=8]"))

        -- Turn on all computers
        -- 22: GPS
        -- 25: Quarry
        -- 26: Tree Farm Display
        -- 28: Speaker
        -- 30: Prometheus
        -- 31: Prometheus Monitor
        -- 32: Display
        check_command(commands.computercraft("turn-on #22 #26 #28 #30 #31 #32"))

        sleep(30)
    end
end, function()
    peripheral.find("modem", rednet.open)

    while true do
        rednet.receive("squid/quarry-restock")
        print("Refilling the quarry")
        shell.run("/refill")
    end
end)
