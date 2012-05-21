#!/bin/bash
# A UNIX / Linux shell script to restore dirs (linux)
# This script restore both full and differential backups.
# You can run script at midnight or early morning each day using cronjons.
# Script must run as root or configure permission via sudo.
# -------------------------------------------------------------------------
# Copyright (c) 2012 David Trigo <david.trigo@gmail.com>
# This script is licensed under GNU GPL version 3.0 or above
# -------------------------------------------------------------------------
# Last updated on : May-2012 - Script created.
# -------------------------------------------------------------------------
LOGBASE=/var/tmp/log
 
# Backup Log file
LOGFILE=$LOGBASE/$NOW.restore.log

# Restore dir
RESTORE_DIR="/home/david/borrar/recovery_path"

# Backup dir
BACKUP_DIR="/home/david/borrar/"

# Path to binaries
COMPRESSOR=/usr/bin/7z
MKDIR=/bin/mkdir

# -------------------------------------------------------------------------

# Get todays day like 1, 2, .., 7; 1 is Monday
NOW=$(date +"%u")
LAST_FULL_BACKUP_DATE=$(date +%F -d "$NOW day ago")

# Backup filename
LAST_FULL_BACKUP_FILENAME="$LAST_FULL_BACKUP_DATE.7z"
 
# Compression atributes
RESTORE_FULL_ARGS="x"
RESTORE_PARTIAL_ARGS="-aoa -y"

# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

 
#### Custom functions #####
# Restore a full backup
full_restore(){
	local old=$(pwd)
	cd $RESTORE_DIR
	$COMPRESSOR $RESTORE_FULL_ARGS $BACKUP_DIR$LAST_FULL_BACKUP_FILENAME
	cd $old
}
 
# Restore a  partial backup
partial_restore(){
	local old=$(pwd)
	local LAST_BACKUP_DATE=$(date +%F -d "$1 day ago")
	local BACKUP_FILENAME="$LAST_BACKUP_DATE.7z"
	cd $RESTORE_DIR
	$COMPRESSOR $RESTORE_FULL_ARGS $BACKUP_DIR$BACKUP_FILENAME $RESTORE_PARTIAL_ARGS
	cd $old
}

 
#### Main logic ####
 
# Make sure log dir exits
[ ! -d $LOGBASE ] && $MKDIR -p $LOGBASE

# Make sure restore dir exits
[ ! -d $RESTORE_DIR ] && $MKDIR -p $RESTORE_DIR
 
# Okay let us start restore procedure
# If it is Sunday restore a full backup;
# For Mon to Fri restore a differential backup
# Saturday no backups

full_restore > $LOGFILE 2>&1

for i in $(seq $(expr $NOW - 1) -1 0);do
	partial_restore $i >> $LOGFILE 2>&1
done
