while true do
    local req, err = http.get("http://localhost:9226/metrics")
    if not req then
        printError(err)
    else
        local body = req.readAll()
        req.close()

        local req, err, err_req = http.post("https://squiddev.cc/blanketcon/metrics", body)
        if not req then
            printError(err)
            if err_req then
                printError(("Returned HTTP %d %s"):format(err_req.getResponseCode()))
            end
        end
    end

    local deadline = os.epoch("utc") + 15 * 1000
    repeat sleep(1) until os.epoch("utc") >= deadline
end
