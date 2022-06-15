local modems = {
  ["modem_3"] = { 7, 53, 335 },
  ["modem_4"] = { 7, 46, 335 },
  ["modem_1"] = { 7, 46, 328 },
  ["modem_0"] = { 0, 46, 328 },
}

local served = 0
local timer = nil

peripheral.call(next(modems), "open", gps.CHANNEL_GPS)

while true do
  term.clear()
  term.setCursorPos(1, 1)
  term.write("Served " .. served)

  local event, arg, channel, reply_channel, message, distance = os.pullEvent()
  if event == "timer" and arg == timer then
    timer = nil
  elseif event == "modem_message" and channel == gps.CHANNEL_GPS and message == "PING" and distance and not timer then
    for modem, message in pairs(modems) do
        peripheral.call(modem, "transmit", reply_channel, gps.CHANNEL_GPS, message)
    end
    served = served + 1

    timer = os.startTimer(0.05)
  end
end
