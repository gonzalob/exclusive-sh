#!/bin/sh
CONFIG=/etc/default/exclusive-sh
LOCKDIR=/var/lock/exclusive-sh

lockdir_not_available() {
 echo "Lock directory $LOCKDIR not found. $0 -h for help."
 exit 1
}

usage() {
 cat 1>&2 << EOF
Usage: $0 [options]
where options is:
-c use given alternative config file
-q quiet
-l lock execution with using the given lock name
-d use specified lock directory
-t task to execute
EOF
 exit
}

acquire_lock() {
 if [ -n "$1" ]; then
  log "Locking exclusive shell execution with name $LOCKNAME..."
  echo $! > $LOCKDIR/$LOCKNAME
  complete
 fi
}

release_lock() {
 if [ -n "$1" ]; then
  log "Releasing exclusive shell execution lock $LOCKNAME..."
  rm $LOCKDIR/$LOCKNAME
  complete
 fi
}

log() {
 [ "$VERBOSE" = false ] || echo -n "$1"
}

complete() {
 [ "$VERBOSE" = false ] || echo ' done.'
}

while getopts l:c:d:t:hq opt; do
 case "$opt" in
  l) LOCKNAME=$OPTARG;;
  c) CONFIG=$OPTARG;;
  d) LOCKDIR=$OPTARG;;
  t) TASK=$OPTARG;;
  q) VERBOSE=false;;
  h|*) usage;;
 esac
done

[ -d "$LOCKDIR" ] || lockdir_not_available

log 'Waiting for exclusive shell script execution to be allowed...'
while [ "`ls -A $LOCKDIR`" ]; do echo -n .; sleep 1; done
complete

acquire_lock $LOCKNAME
$TASK
release_lock $LOCKNAME
