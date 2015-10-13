#!/bin/bash
set -e

LYCHEE_CONFIG_FILE=/var/www/lychee/data/config.php

if ! [ -f $LYCHEE_CONFIG_FILE ]; then
	# DB Host
	if [ -n "$MYSQL_PORT_3306_TCP" ]; then
		LYCHEE_DBHOST=mysql
		echo >&2 'Link exist, setting database host to 'mysql''
	else
		# Default values added in the Docker file
		echo >&2 'Mysql Link is missing, setting database host to LYCHEE_DBHOST default(localhost)'
	fi

	echo -e "<?php\nif(!defined('LYCHEE')) exit('Error: Direct access is not allowed!');" >> $LYCHEE_CONFIG_FILE
	echo -e "\$dbHost = '$LYCHEE_DBHOST';" >> $LYCHEE_CONFIG_FILE

	# DB Password
	if [ -n "MYSQL_PORT_3306_TCP" ];then
		: ${LYCHEE_DBPASS:=$MYSQL_ENV_MYSQL_PASS}
	fi
	echo -e "\$dbPassword = '$LYCHEE_DBPASS';" >> $LYCHEE_CONFIG_FILE

	# DB User
	echo -e "\$dbUser = '$LYCHEE_DBUSER';" >> $LYCHEE_CONFIG_FILE
	# DB Name
	echo -e "\$dbName = '$LYCHEE_DBNAME';" >> $LYCHEE_CONFIG_FILE
	# DB Table Prefix
	echo -e "\$dbTablePrefix = '$LYCHEE_TBLPREFIX';\n?>" >> $LYCHEE_CONFIG_FILE
fi

# Change permissions for application folder 
chown -R www-data:www-data /var/www/lychee
chmod -R 770 /var/www/lychee
chmod -R 777 /var/www/lychee/uploads/
chmod -R 777 /var/www/lychee/data/


# Run the FPM and Nginx
supervisord -c /etc/supervisor/supervisord.conf
