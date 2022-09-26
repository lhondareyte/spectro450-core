#!/bin/sh
#
# This file is part of the Spectro450 Project.
#
# Copyright (c)2022, Luc Hondareyte
#

export pkgdb="/var/db/pkg/local.sqlite"
export spectrodb="/etc/spectro.conf"
export sql="/usr/local/bin/sqlite3"


listApplications () {
	$sql $pkgdb "select name from packages where prefix ='/Applications';" \
		| awk ' { printf("%s\n",toupper(substr($0,1,1))substr($0,2)) }'
}
