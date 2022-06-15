import json
from PIL import Image

width, height = 128, 128
maps = [
    [33, 31, 35, 37],
    [25, 19, 21, 39],
    [27, 23, 29, 41],
]

original_map = Image.new("RGB", (width * 4, height * 3))
decorations = []

for y0, row in enumerate(maps):
    for x0, map in enumerate(row):
        with open(f".minecraft/maps/map_{map}.json") as h:
            this_map = json.load(h)
        colours = this_map["colours"]

        for x in range(width):
            for y in range(height):
                colour = colours[x + y * 128]
                original_map.putpixel(
                    (x + x0 * width, y + y0 * width),
                    (
                        int(colour[0:2], 16),
                        int(colour[2:4], 16),
                        int(colour[4:6], 16),
                    ),
                )
        for decoration in this_map["decorations"]:
            if "label" not in decoration:
                continue

            print(f"Decoration => {decoration['label']}")
            decorations.append(
                "{%d,%d,[[%s]]}"
                % (
                    int(decoration["x"] / 2 + 64) + x0 * width,
                    int(decoration["z"] / 2 + 64) + y0 * height,
                    decoration["label"],
                )
            )

original_map.save("_build/map-original.png")

quantised_map = original_map.quantize(colors=16, dither=Image.Dither.NONE)


def render_map(out, map, scale):
    map.save(f"_build/map-{scale}.png")

    width, height = map.size
    print(f"Map scale={scale} => {width} x {height}")

    out.write("{")
    for y in range(height):
        out.write('"')
        for x in range(width):
            out.write("%x" % map.getpixel((x, y)))
        out.write('",')
    out.write("scale=%d}," % scale)


with open("src/guide/disk/src/map_data.lua", "w") as h:
    palette = quantised_map.getpalette()
    h.write("return {palette={")
    for p in range(16):
        h.write(
            f"{palette[p * 3] << 16 | palette[p * 3 + 1] << 8 | palette[p * 3 + 2]},"
        )
    h.write("},decorations={")
    h.write(",".join(decorations))
    h.write("},map={")

    render_map(h, quantised_map, 1)
    render_map(h, original_map.reduce(2).quantize(colors=16, palette=quantised_map), 2)
    render_map(h, original_map.reduce(3).quantize(colors=16, palette=quantised_map), 3)
    render_map(h, original_map.reduce(4).quantize(colors=16, palette=quantised_map), 4)

    h.write("}}\n")
