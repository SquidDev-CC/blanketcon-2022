local function fmt(x)
    return x:gsub("^\n", ""):gsub("\\(%d+)", function(x) return string.char(tonumber(x)) end)
end

local M = {}
M.help = fmt [[
# Map controls
+-/Mouse scroll
  Zoom In/Out

wasd/hjkl/\24\25\26\27
  Move map

Space
  Recenter map

?
  Show help

# Info box controls
Backspace
  Close info box

ws/jk/\24\25/PgUp/PgDown
  Scroll text
]]

M.zones = {}
local function zone(min_x, min_z, max_x, max_z, text)
    return {
        min_x = min_x, min_z = min_z,
        max_x = max_x, max_z = max_z,
        text = fmt(text),
    }
end

M.zones.welcome = zone(-5, 322, 8, 333, [[
# Welcome!
Hello and welcome to the
CC: Restitched booth. CC:R
is a port of ComputerCraft
for Fabric, adding fantasy
programmable computers to
Minecraft.

These computers come with
all sorts of tools to help
you get started with
automating your Minecraft
world!

Keep hold of this pocket
computer, it'll be your
guide throughout this
booth.

# More about CC: Restitched
CC:R is developed by
Merith, ToadDev, and many,
many more contributors.

Check out the source code
(github.com/cc-tweaked),
documentation (tweaked.cc)
and get started on your
programming journey!
]])

M.zones.tree_farm = zone(14, 340, 25, 350, [[
# Turtles and Tree Farms
Turtles are little robots
which can move around the
world, breaking and
placing blocks.

Here we've got a small
turtle-powered tree farm.
The turtle pulls saplings,
fuel and bonemeal from the
chest below, and then uses
those to plant and grow
the tree before chopping
it down.

# Turtle upgrades
Notice our turtle holds
a tool on each side. On
the right, an axe - we
need this to chop down
trees!

The left meanwhile holds a
wireless modem. This is
used to talk to other
nearby computers.

In this case, we tell the
other computer how much
we've been chopping, which
is then drawn on the
monitor.
]])

M.zones.speaker = zone(-3, 337, 5, 343, [[
# Speakers
CC:R comes with a whole
bunch of 'peripherals' -
other blocks which can be
controlled by computers.

Speakers are one such
peripheral. They allow you
to play arbitrary audio;
from a file, the internet
or procedurally generated
by the computer itself!

You might need to turn
down the in-game music so
you can hear a little
better.
]])

M.zones.c33d = zone(-4, 347, 6, 352, [[
# Silly nonsense
Look, I don't know. If you
go about 8-10 blocks away,
there's no other players
in the area, and you
squint a bit it's almost
convincing. Almost.

But I had fun making it,
and honestly that's the
main point of using CC:R!
]])

M.zones.prometheus = zone(-11, 344, -5, 350, [[
# Metrics and Prometheus
One of the big problems
with running a Minecraft
server is working out
where the lag is coming
from.

CC:R heavily rate limits
computers, so you can rest
easy with the knowledge
that computers aren't the
cause of your lag issues.

However, if you're still
not sure, it also has a
whole suite of admin and
monitoring tools under the
/computercraft command, as
well as a Prometheus
exporter so you can keep
an eye without even being
online.
]])

M.zones.furnace = zone(16, 329, 27, 337, [[
# Containers and Code
CC:R comes with several
peripherals - other blocks
it can control - like
speakers or monitors.

However, it can also treat
any vanilla inventory as
a peripheral, allowing you
to inspect the contents of
a chest, and even move
items through networking
cables.

These three furnaces and
the tree farm chest are
networked together through
the use of wired modems
and cable. With a little
bit of code, we can
automatically smelt any
wood our farm makes, using
the charcoal to refuel our
furnaces and turtle!
]])

M.zones.chest = zone(6, 344, 13, 351, [[
# AE2 for Yak Shavers
As mentioned over by the
furnaces, CC:R computers
can inspect and control
inventories.

With an awful lot of code,
and even more time, you
can build your own item
management system, great
for keeping your chests
sorted in the early game!
]])

M.zones.quarry = zone(-19, 334, -9, 344, [[
# Going Underground
Turtles are little robots
which can be programmed to
do all the things you
don't want to do.

This one here is equipped
with a pickaxe and is busy
quarrying out this big
hole.

Turtles are incredible
flexible, only limited by
your ingenuity. Instead of
quarrying, you could write
a program to skip cobble
and search for valuable
ores. Or maybe network a
whole horde of turtles
together? Maybe even have
them replicate?

Who knows? It's all up to
you!
]])

M.zones.stage = zone(-75, -211, -35, -174, [[
# The Main Stage
Welcome to the main stage!
Did you know, this whole
thing is powered by an
ungodly mismash of Create,
command blocks and CC:R!

Trust me, you don't want
to see the wiring. Or the
code.
]])

for name, zone in pairs(M.zones) do zone.name = name end

return M
