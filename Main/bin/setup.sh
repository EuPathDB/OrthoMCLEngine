#!/bin/bash 
#
# ~ setup.sh ~
#
# Start a user instance of MySQL
#
#  OrthoMCL v1.0
#

BASE_DIR=$( dirname $( readlink -f -- "${0%/*}" ))

# change security level of mysql.so per SeLinux restrictions
chcon -t textrel_shlib_t $HOME/OrthoMCL/lib/perl/i386-linux-thread-multi/auto/DBD/mysql/mysql.so 

# attempt to start mysqld
echo "Attempting to start MySQL server...."
cd $HOME/OrthoMCL/db
./bin/mysqld_safe \
     --defaults-file=$BASE_DIR/config/mysql.cnf \
     --basedir=$BASE_DIR/db \
     --skip-networking \
     --skip-grant-tables \
     --skip-innodb \
     --datadir=$BASE_DIR/db/data \
     --socket=$BASE_DIR/db/tmp/myortho.sock  \
     --key_buffer_size=64M  \
     --myisam-recover \
     --tmpdir=$BASE_DIR/db/tmp  \
     --pid-file=$BASE_DIR/db/tmp/myortho.pid  \
     --language=$BASE_DIR/db/share/english  \
     --log-error=$BASE_DIR/db/tmp/myortho.log 2>&1 &
