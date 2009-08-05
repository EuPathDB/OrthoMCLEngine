#!/bin/sh
#
# ~ shutdown.sh ~
#
# Shutdown a user instance of MySQL
#
#
#

BASE_DIR=$( dirname $( readlink -f -- "${0%/*}" ))

pidFile=$BASE_DIR/db/tmp/myortho.pid

if cat $pidFile; then
   pid=`cat $pidFile`
else
   echo "ERROR: No pid file exists for this host."
   echo "Check to ensure that MySQL is actually running."
   exit 0
fi
   
echo "Shutting down MySQL server..."
kill -15 $pid 

