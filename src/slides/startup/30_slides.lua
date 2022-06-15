print("Behold, my terrible wiring!")

if pocket then
    shell.run("/slide-control")
else
    term.setTextColour(colours.green)
    print("Run `/slides [IMGUR ALBUM]' to start a slideshow")
    term.setTextColour(colours.white)

    os.queueEvent("paste", "/slides https://imgur.com/a/38KMRGa")
end
