{ helpers, pkgs }:
with pkgs;
runCommand "conkeror-works"
  {
    buildInputs = [ xvfb_run conkeror procps ];
  }
  ''
    timeout 30 xvfb-run conkeror "http://google.com" &
    PID="$!"

    sleep 20

    MSG="Conkeror doesn't crash on startup"
    if pgrep ".*conkeror.*"
    then
      echo "ok - $MSG" > "$out"
    else
      echo "not ok - $MSG" 1>&2
    fi

    kill "$PID" 1> /dev/null 2> /dev/null
  ''
