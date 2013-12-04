#!/bin/sh
CONFIG=/etc/default/exclusive-sh
LOCKDIR=/var/lock/exclusive-sh
LOCKS=
WAIT=
TASK=
VERBOSE=true

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
-l lock execution with using the given lock name. may be used more than once
-d use specified lock directory
-t task to execute
-w wait on lock. may be used more than once
EOF
 exit
}

acquire_locks() {
 if [ -n "$LOCKS" ]; then
  log 'Locking exclusive shell execution'
  for LOCK in $LOCKS; do
   log " ($LOCK)..."
   echo $! > $LOCKDIR/$LOCK
  done
  complete
 fi
}

release_locks() {
 if [ -n "$LOCKS" ]; then
  log 'Releasing exclusive shell execution'
  for LOCK in $LOCKS; do
   log " ($LOCK)..."
   rm $LOCKDIR/$LOCK
  done
  complete
 fi
}

log() {
 [ "$VERBOSE" = true ] && echo -n "$1"
}

complete() {
 [ "$VERBOSE" = true ] && echo ' done.'
}

load_config() {
 [ -r "$CONFIG"  ] && . $CONFIG
 [ -d "$LOCKDIR" ] || lockdir_not_available
}

wait_on_locks() {
 log 'Waiting for exclusive shell script execution to be allowed...'
 QUERY=-false
 for LOCK in $WAIT; do QUERY="$QUERY -o -name $LOCK"; done
 while [ "`find $LOCKDIR $QUERY`" ]; do echo -n .; sleep 1; done
 complete
}


while getopts l:c:d:t:hqw: opt; do
 case "$opt" in
  l) LOCKS="$LOCKS $OPTARG";;
  c) CONFIG=$OPTARG;;
  d) LOCKDIR=$OPTARG;;
  t) TASK=$OPTARG;;
  q) VERBOSE=false;;
  w) WAIT="$WAIT $OPTARG";;
  h|*) usage;;
 esac
done

load_config
wait_on_locks
acquire_locks
$TASK
release_locks
