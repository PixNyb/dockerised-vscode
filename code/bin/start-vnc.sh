#!/usr/bin/env bash

set -eou pipefail

PASSWORD="${VNC_PASSWORD:-}"
GEOMETRY="${VNC_GEOMETRY:-1920x1080}"

if [ -n "$PASSWORD" ]; then
  SECURITY="-SecurityTypes VncAuth -PasswordFile $HOME/.vnc/passwd"
  mkdir -p $HOME/.vnc
  echo "$PASSWORD" | vncpasswd -f > $HOME/.vnc/passwd
  chmod 600 $HOME/.vnc/passwd
else
  SECURITY="-SecurityTypes None"
fi

echo "- Starting VNC server..."

rm -f /tmp/.X*-lock
/opt/TurboVNC/bin/vncserver -geometry $GEOMETRY -depth 24 -rfbport 5900 $SECURITY -xstartup openbox $DISPLAY

echo "- VNC started..."
