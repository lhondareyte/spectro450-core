#!/bin/sh
#
# This file is part of the Spectro450 Project.
#
# Copyright (c)2016-2022, Luc Hondareyte
#

PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin"

export platform="$(uname -s)/$(uname -m)"
export libexec="/usr/local/libexec/spectro450"
export appRoot="/Applications"
export libRoot="/Library"
export conf="/etc/spectro450.conf"
export media="/media/usb"
export flatname="$(echo $app | tr '[A-Z]' '[a-z]')"

export appdir="${appRoot}/${app}"
export ctndir="${appdir}/Contents/${platform}"
export appbin="${ctndir}/${flatname}"
export apprun="${appdir}/${flatname}"
export dialog="${libexec}/dialog"
export libdir="${libRoot}/${app}"
export rscdir="${appdir}/Resources"
export log="/tmp/${flatname}.log"

export PATH="${appdir}:${libexec}:$PATH"

[ ! -f ${libexec}/libsql.sh ] || . ${libexec}/libsql.sh
[ ! -f $conf ]                || . $conf
[ ! -z $JACK ] && export JACK || export JACK="NO"
[ ! -z $_TTY ] && export _TTY || export _TTY="/dev/console"
[ ! -z $TERM ] && export TERM || export TERM="xterm"

if [ -z $appbin ] ; then
	pid=$(pgrep $apprun)
else
	pid=$(pgrep $appbin)
fi

Log() {
	echo "$*" >> $log
}

Exec () {
	$* >> $log 2>&1
	rc=$?
	if [ $rc -ne 0 ] ; then
		printf "$1 : command failed! Consult $log for details\n"
		Log "$*: failed"
		exit  $rc
	fi
	Log "$*: ok."
	return $rc
}

quiet () {
	$* > /dev/null 2>&1 ; return $?
}

SaveAllFiles () {
	Exec mount /cfg 
	cd /cfg
	printf "Saving configuration "
	find . -type f | while read f
	do
		Exec cp -p /etc/$f .
		printf "."
		sleep 1
	done
	echo "done."
	sleep 1
	sync;sync;sync
	cd && Exec umount /cfg
}

SaveSomeFiles () {
	Exec mount /cfg 
	for f in $*
	do
		if [ -f /etc/$f ] ; then
			cp -p /etc/$f /cfg/$f
		fi
	done
	sync;sync;sync
	Exec umount /cfg 
}

SaveConfig () {
	if [ $# -eq 0 ] ; then
		SaveAllFiles
	else
		SaveSomeFiles $*
	fi 
}

Panic () {
	$dialog -k "$1" "PressAKey"
	/sbin/shutdown -p now
}

UmountUsbDrive () {
	umount $media
}

MountUsbDrive () {
	mount -t msdosfs $1 $media
}

ToggleRW () {
	Log "Toggle all FS read-write"
	Exec mount -orw /
	for m in /Applications /Library /Data
	do
		Exec umount $m
	done
	for m in /Data /Library /Applications
	do
		Exec mount -orw $m
	done
	Exec -orw /
}

ToggleRO () {
	Log "Toggle all FS read-only"
	for m in /Applications /Library /Data
	do
		Exec umount $m
	done
	for m in /Data /Library /Applications
	do
		Exec mount -oro $m
	done
	Exec -orw /
}

JackRegister () {
        device=$1
        app_midi_port=$(jack_lsp | awk '/noizebox/ && /midi_/ {print}')
        jack_umidi -nspectro -kBd /dev/$device
        jack_connect spectro-${device}:midi.TX $app_midi_port
}

MakeRamdisk () {
	mount_point=$1
        if [ "$ramdisk" != "YES" ] && [ "$ramdisk" != "yes" ] ;  then
                return 0
        fi
        if [ -f /etc/ramdisk.conf ] ; then
                . /etc/ramdisk.conf
        else
                RAMDISK_SIZE=256m
        fi
        MD=$(mdconfig -a -t swap -s $RAMDISK_SIZE 2>/dev/null)
        [ $? -ne 0 ] && return 0
        quiet newfs -U /dev/$MD
        mount -t ufs /dev/$MD /Ramdisk
	mkdir -p $mount_point
}

DeleteRamdisk () {
        MD=$(mount | awk '/\/Ramdisk/ {print $1}')
        [ -z $MD ] && return 0
        quiet umount -f /Ramdisk
        quiet mdconfig -d -u ${MD}
}

Reboot () {
	SaveConfig
	/sbin/reboot
}

Poweroff () {
	SaveConfig
	/sbin/shutdown -p now
}

