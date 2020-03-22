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

export TERM=tinyVT
export PATH="/bin:/sbin:/usr/bin:/usr/sbin"
export TEXTDOMAIN=NanoUpgrade
libexec="/usr/local/libexec/spectro450"
dialog="${libexec}/dialog"
conf="/etc/spectro-450.conf"
media="/media/usb"

if [ ! -z $tty ] ; then
	tty="/dev/spectro450"
fi

if [ -z $app_bin ] ; then
	pid=$(pgrep $(basename $0))
else
	pid=$(pgrep $(basename $app_bin))
fi

Exec () {
	$* >> $LOG 2>&1
	rc=$?
	if [ $rc -ne 0 ] ; then
		printf "$1 : command failed! Consult $LOG for details\n"
		exit  $rc
	fi
	return $rc
}

quiet () {
	$* > /dev/null 2>&1 ; return $?
}

SaveAllFiles () {
	Exec mount /cfg 
	cd /cfg
	find . -type f | while read f
	do
		Exec cp -p /etc/$f .
	done
	sync;sync;sync
	cd && Exec umount /cfg
}

SaveSomeFiles () {
	cd && Exec mount /cfg 
	for f in $ARGS
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
	mount -t msdosfs -o ro $device $media
}

Toggle_RW () {
	Exec mount -orw /
	Exec umount /Applications
	Exec umount /Library
	Exec umount /Data
	Exec monut -orw /Data
	Exec mount -orw /Applications
	Exec mount -orw /Library
}

Toggle_RO () {
	Exec umount /Applications
	Exec umount /Library
	Exec umount /Data
	Exec monut  /Data
	Exec mount  /Applications
	Exec mount  /Library
	Exec mount -oro /
}
