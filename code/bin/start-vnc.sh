#!/usr/bin/env bash

set -o pipefail -o nounset

echo "- Starting VNC server..."

rm -f /tmp/.X*-lock
/opt/TurboVNC/bin/vncserver -geometry 1920x1080 -depth 24 -rfbport 5900 -SecurityTypes None -xstartup openbox $DISPLAY
VNC_PID=$!

echo "- VNC started on pid ${VNC_PID}..."
