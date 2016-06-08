#!/bin/bash
### BEGIN INIT INFO
# Provides:          $NAME
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: $NAME: Climb Over the Wall http proxy
# Description:       Automatically detect blocked site and use parent proxy.
### END INIT INFO

# Put this script under /etc/init.d/, then run "update-rc.d $NAME defaults".

# Note: this script requires sudo in order to run $NAME as the specified
# user. Please change the following variables in order to use this script.
# COW will search for rc/direct/block/stat file under user's $HOME/.cow/ directory.
NAME=cow
BIN="/usr/local/bin/cow"
USER=tzdadmin
GROUP=tzdadmin

PID_DIR=/var/run
PID_FILE=$PID_DIR/$NAME.pid
LOG_FILE=/var/log/$NAME.log

RET_VAL=0

check_running() {
  if [[ -r $PID_FILE ]]; then
    read PID <$PID_FILE
    if [[ -d "/proc/$PID" ]]; then
      return 0
    else
      rm -f $PID_FILE
      return 1
    fi
  else
    return 2
  fi
}


do_status() {
  check_running
  case $? in
    0)
      echo "$NAME running with PID $PID"
      ;;
    1)
      echo "$NAME not running, remove PID file $PID_FILE"
      ;;
    2)
      echo "Could not find PID file $PID_FILE, $NAME does not appear to be running"
      ;;
  esac
  return 0
}

do_start() {
  if [[ ! -d $PID_DIR ]]; then
    echo "creating PID dir"
    mkdir $PID_DIR || echo "failed creating PID directory $PID_DIR"; exit 1
    chown $USER:$GROUP $PID_DIR || echo "failed creating PID directory $PID_DIR"; exit 1
    chmod 0770 $PID_DIR
  fi
  if check_running; then
    echo "$NAME already running with PID $PID"
    return 0
  fi
  echo "starting $NAME"

  # sudo will set the group to the primary group of $USER
  sudo -u $USER -H -- $BIN >$LOG_FILE 2>&1 &
  PID=$!
  
  
  echo $PID > $PID_FILE
  sleep 0.3
  if ! check_running; then
    echo "start failed"
    return 1
  fi
  echo "$NAME running with PID $PID"
  return 0
}

do_stop() {
  if check_running; then
    echo "stopping $NAME with PID $PID"
    kill $PID
    rm -f $PID_FILE
  else
    echo "Could not find PID file $PID_FILE"
  fi
}

do_restart() {
  do_stop
  do_start
}

case "$1" in
  start|stop|restart|status)
    do_$1
    ;;
  *)
    echo "Usage: $NAME {start|stop|restart|status}"
    RET_VAL=1
    ;;
esac

exit $RET_VAL
