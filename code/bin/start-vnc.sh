rm -f /tmp/.X*-lock
/opt/TurboVNC/bin/vncserver -geometry 1920x1080 -depth 24 -rfbport 5900 -SecurityTypes None -xstartup openbox $DISPLAY
