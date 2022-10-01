#!/bin/sh
#
# This file is part of the Spectro450 Project.
#
# Copyright (c)2022, Luc Hondareyte
#

export pkgdb="/var/db/pkg/local.sqlite"
export spectrodb="/etc/spectro.conf"
export sql="sqlite3"
export PATH=$PATH:/usr/local/bin

listApplications () {
	$sql $pkgdb "
	SELECT name FROM packages 
	WHERE prefix ='/Applications';" \
	| awk ' { printf("%s\n",toupper(substr($0,1,1))substr($0,2)) }'
}

listConfigFiles () {
	local app=$1
	$sql $pkgdb "
	SELECT path FROM files
	WHERE path LIKE '%/etc/%.conf' AND package_id = (
		SELECT id FROM packages
		WHERE name = '${app}' AND prefix = '/Applications'
	);"
}

