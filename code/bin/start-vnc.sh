rm -f /tmp/.X*-lock
Xvfb ${DISPLAY} -screen 0 1920x1080x24 &
x11vnc -shared -forever -display ${DISPLAY} -rfbport 5900 -nopw -xkb -noxrecord -noxfixes -noxdamage -xrandr -quiet -bg -o /tmp/x11vnc.log
