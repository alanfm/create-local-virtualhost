#!/bin/bash

VHOST=${VHOST}
FLAG=${FLAG}

# Usage
# ---------------------------------------------------\
usage()
{
cat << EOF

Usage: $0 options

OPTIONS:
   -c      Create VirtualHost
   -r      Remove VirtualHost

Example: $0 -c vhost
   
EOF
}

while [[ $# > 1 ]]
do
	key="$1"
	shift

	case $key in
	-c|--create)
	VHOST="$1"
	DOMAIN_NAME="$1.$domain"
	echo=$DOMAIN_NAME
	FLAG="1"
	shift
	;;
	-r|--remove)
	VHOST="$1"
	FLAG="2"
	shift
	;;
esac
done

if [[ "$FLAG" == "" ]]
	then
	usage
fi

# Variables
#-------------------------------------------------------------
domain="local"
DOMAIN_NAME=$VHOST.$domain

public_html="public_html"
webroot="/var/www"


CHOWNERS="root:webdevs"
DIRECTORY=$webroot/$DOMAIN_NAME/$public_html
INDEX_HTML="$DIRECTORY/index.html"
PATH_TO_CONF="/etc/httpd/sites-created"
CONF_FILE="$PATH_TO_CONF/$DOMAIN_NAME.conf"
CONF_FILE_NAME="$DOMAIN_NAME.conf"
LOCAL_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

if [[ "$FLAG" == "1" ]]
	then
	echo "Creating $VHOST"
	
	# Create VirtualHost
	#-------------------------------------------------------------

	echo -e "Your mashine IP: $LOCAL_IP\n"
	echo -e "Try create VirtualHost folder - $DIRECTORY\n"

	if [ -d "$DIRECTORY" ]; then
  	# if exist
  	echo -e "Directory exist"
  	echo -e "Exit!"
  else
  	# not exist
  	/usr/bin/mkdir -p $DIRECTORY
  	echo -e "Folders created: $DIRECTORY"

  	/usr/bin/touch $INDEX_HTML

  	echo "<html>" > $INDEX_HTML
	echo " <head>" >> $INDEX_HTML
	echo "    <title>$DOMAIN_NAME</title>" >> $INDEX_HTML
	echo " </head>" >> $INDEX_HTML
	echo " <body>" >> $INDEX_HTML
	echo "    <h1>$DOMAIN_NAME working!</h1>" >> $INDEX_HTML
	echo " </body>" >> $INDEX_HTML
	echo "</html>" >> $INDEX_HTML
	echo -e "File $INDEX_HTML created"

	/usr/bin/chown -R $CHOWNERS $webroot/$DOMAIN_NAME
	/usr/bin/chmod -R 775 $webroot/$DOMAIN_NAME

	/usr/bin/mkdir -p /etc/httpd/sites-created
	/usr/bin/mkdir -p /etc/httpd/sites-enabled

	/usr/bin/touch $CONF_FILE

	echo "<VirtualHost *:80>" > $CONF_FILE
	echo "ServerName www.$DOMAIN_NAME" >> $CONF_FILE
	echo "ServerAlias $DOMAIN_NAME" >> $CONF_FILE
	echo "DocumentRoot /var/www/$DOMAIN_NAME/public_html" >> $CONF_FILE
	echo "ErrorLog /var/www/$DOMAIN_NAME/error.log" >> $CONF_FILE
	echo "CustomLog /var/www/$DOMAIN_NAME/requests.log combined" >> $CONF_FILE
	echo "</VirtualHost>" >> $CONF_FILE

	/usr/bin/ln -s $CONF_FILE /etc/httpd/sites-enabled/$CONF_FILE_NAME

	echo "$LOCAL_IP $DOMAIN_NAME" >> /etc/hosts

	service httpd restart

	echo -e "Please add include conf folder into httpd.conf"
	echo -e "IncludeOptional sites-enabled/*.conf"
	echo -e "Directory $DOMAIN_NAME created"

fi

	#echo "$1"

echo -e "\n"

	# --------------
fi

if [[ "$FLAG" == "2" ]]
	then
	echo "Removing $VHOST"
fi

