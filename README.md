# BlanketCon 2022 Scripts
Various scripts written for the CC:R booth at [BlanketCon 2022].

Please note that many of these programs were hacked together (or at least
heavily modified) specifically for the con to quite a tight deadline. The code
quality is not the best, and they'll probably require a lot of modification to
make them work.

## Interesting projects
 - `src/c33d`: Frontend to c33d (currently unreleased), which renders a 3D scene
   to a monitor.
 - `src/guide`: Guide and minimap around the CC booth.
 - `src/prometheus-display`: Displays metrics from [CC Prometheus] on a monitor.
 - `src/slides`: Slideshow and Q&A system using [PictureSign] and a command
   computer.
 - `src/speaker`: Basic DJ program.
 - `src/tree-farm`/`src/tree-farm-monitor`: A basic tree farm. Please don't use
   this, it's _terrible_.

## Support projects
 - `src/gps`: GPS array which serves the whole server. Relatively uninteresting.
 - `src/no-terminate`: Wrapper script which prevents a user terminating the
    computer.
 - `src/prometheus`: Scrapes the local [CC Prometheus] exporter and pushes it to
   a remote host.
 - `src/watchdog`: Cleans up XP and keeps computers powered on.

[Blanketcon 2022]: https://blanketcon.modfest.net/
[CC Prometheus]: https://github.com/SquidDev-CC/cc-prometheus
[PictureSign]: https://github.com/TeamMidnightDust/PictureSign/
