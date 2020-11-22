#!/bin/sh
#
# This file is part of the Spectro450 Project.
#
# Copyright (c)2016-2020,  Luc Hondareyte
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in 
#    the documentation and/or other materials provided with the distribution.   
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin"

export platform="$(uname -s)/$(uname -p)"
export libexec="/usr/local/libexec/spectro450"
export appRoot="/Applications"
export libRoot="/Library"
export conf="/etc/spectro450.conf"
export media="/media/usb"
export log="/tmp/$(basename $0).log"

export appdir="${appRoot}/${app}"
export app_bin="${ctndir}/$(echo $app | tr '[A-Z]' '[a-z]')"
export app_run="${appdir}/$(echo $app | tr '[A-Z]' '[a-z]')"
export ctndir="${appdir}/Contents/${platform}"
export dialog="${libexec}/dialog"
export libdir="${libRoot}/${app}"
export rscdir="${appdir}/Resources"

export PATH="${appdir}:${libexec}:$PATH"


if [ -f $conf ] ; then
	. $conf
fi

[ ! -z $JACK ] && export JACK || export JACK="NO"
[ ! -z $_TTY ] && export _TTY || export _TTY="/dev/console"
[ ! -z $TERM ] && export TERM || export TERM="xterm"

if [ -z $app_bin ] ; then
	pid=$(pgrep $(basename $0))
else
	pid=$(pgrep $(basename $app_bin))
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
	device=$1
	mount -t msdosfs $device $media
}

Toggle_RW () {
	Log "Toggle all FS read-write"
	Exec mount -orw /
	Exec umount /Applications
	Exec umount /Library
	Exec umount /Data
	Exec mount -orw /Data
	Exec mount -orw /Applications
	Exec mount -orw /Library
}

Toggle_RO () {
	Log "Toggle all FS read-only"
	Exec umount /Applications
	Exec umount /Library
	Exec umount /Data
	Exec mount -oro /
	Exec mount  /Data
	Exec mount  /Applications
	Exec mount  /Library
}

Jack_Register () {
        device=$1
        app_midi_port=$(jack_lsp | awk '/noizebox/ && /midi_/ {print}')
        jack_umidi -nspectro -kBd /dev/$device
        jack_connect spectro-${device}:midi.TX $app_midi_port
}

Reboot () {
	SaveConfig
	/sbin/reboot
}

Poweroff () {
	SaveConfig
	/sbin/shutdown -p now
}
