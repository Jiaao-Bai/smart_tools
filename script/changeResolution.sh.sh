#！/bin/bash
# ubuntu change the resolution to 2560*1080
cvt 2560 1080 60
xrandr --newmode "2560x1080_60.00"  230.00  2560 2720 2992 3424  1080 1083 1093 1120 -hsync +vsync
xrandr --addmode Virtual1 "2560x1080_60.00"
xrandr -s 2560x1080_60.00
