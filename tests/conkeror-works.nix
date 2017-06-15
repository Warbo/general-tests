#! /usr/bin/env nix-shell
#! nix-shell -i bash -p xvfb_run conkeror

timeout 30 xvfb-run conkeror "http://google.com" &
PID="$!"

sleep 20

MSG="Conkeror doesn't crash on startup"
if pgrep ".*conkeror.*"
then
    echo "ok - $MSG"
else
    echo "not ok - $MSG"
fi

kill "$PID" 1> /dev/null 2> /dev/null
