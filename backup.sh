#!/bin/bash
# A UNIX / Linux shell script to backup dirs (linux)
# This script make both full and differential backups.
# You can run script at midnight or early morning each day using cronjons.
# Script must run as root or configure permission via sudo.
# -------------------------------------------------------------------------
# Copyright (c) 2012 David Trigo <david.trigo@gmail.com>
# This script is licensed under GNU GPL version 3.0 or above
# -------------------------------------------------------------------------
# http://a32.me/2010/08/7zip-differential-backup-linux-windows/
# http://www.articlesbase.com/data-recovery-articles/differential-backup-for-windowslinux-3102569.html
# -------------------------------------------------------------------------
# Last updated on : May-2012 - Script created.
# -------------------------------------------------------------------------
LOGBASE=/var/tmp/log
 
# Backup dirs
BACKUP_ROOT_DIR="/home/david/documentacion/Documentacion/Zimbra"

# Backup dir
BACKUP_DIR="/home/david/borrar/"

# Exclude file
#EXCLUDE_CONF=/root/.backup.exclude.conf
 
# Backup Log file
LOGFILE=$LOGBASE/$NOW.backup.log
 
# Path to binaries
COMPRESSOR=/usr/bin/7z
MKDIR=/bin/mkdir

# -------------------------------------------------------------------------
 
# Get todays day like 1, 2, .., 7; 1 is Monday
NOW=$(date +"%u")
TODAY_DATE=$(date +%F)
LAST_FULL_BACKUP_DATE=$(date +%F -d "$NOW day ago")

# Backup filename
TODAY_FILENAME="$TODAY_DATE.7z"
LAST_FULL_BACKUP_FILENAME="$LAST_FULL_BACKUP_DATE.7z"
 
# Compression atributes
COMPRESION_FULL_ARGS="a -mx=3 -m0=bzip2"
COMPRESION_PARTIAL_ARGS_1="u -mx=9 -m0=bzip2 -ms=off"
# Para ejecutar manualmente desde shell
#COMPRESION_PARTIAL_ARGS_2="-u- -up0q3r2x2y2z0w2\!"
COMPRESION_PARTIAL_ARGS_2="-u- -up0q3r2x2y2z0w2!"
 
# ------------------------------------------------------------------------
# Excluding files when using tar
# Create a file called $EXCLUDE_CONF using a text editor
# Add files matching patterns such as follows (regex allowed):
# /home/david/iso
# /home/david/*.cpp~
# ------------------------------------------------------------------------
# TODO: Pendiente de implementar con 7z
#[ -f $EXCLUDE_CONF ] && 7Z_ARGS="-X $EXCLUDE_CONF"
 
#### Custom functions #####
# Make a full backup
full_backup(){
	local old=$(pwd)
	cd /
	$COMPRESSOR $COMPRESION_FULL_ARGS $BACKUP_DIR$TODAY_FILENAME $BACKUP_ROOT_DIR
	cd $old
}
 
# Make a  partial backup
partial_backup(){
	local old=$(pwd)
	cd /
	$COMPRESSOR $COMPRESION_PARTIAL_ARGS_1 $BACKUP_DIR$LAST_FULL_BACKUP_FILENAME $BACKUP_ROOT_DIR $COMPRESION_PARTIAL_ARGS_2$BACKUP_DIR$TODAY_FILENAME
	cd $old
}
 
# Make sure all dirs exits
verify_backup_dirs(){
	local s=0
	for d in $BACKUP_ROOT_DIR
	do
		if [ ! -d /$d ];
		then
			echo "Error : /$d directory does not exits!"
			s=1
		fi
	done
	# if not; just die
	[ $s -eq 1 ] && exit 1
}
 
#### Main logic ####
 
# Make sure log dir exits
[ ! -d $LOGBASE ] && $MKDIR -p $LOGBASE
 
# Verify dirs
verify_backup_dirs
 
# Okay let us start backup procedure
# If it is Sunday make a full backup;
# For Mon to Fri make a differential backup
# Saturday no backups
case $NOW in
	7)	full_backup;;
	1|2|3|4|5)	partial_backup;;
	*)	;;
esac > $LOGFILE 2>&1
