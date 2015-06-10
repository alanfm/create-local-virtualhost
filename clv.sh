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

# Check arguments
# ---------------------------------------------------\
while [[ $# > 1 ]]
do
	key="$1"
	shift

	case $key in
	-c|--create)
	VHOST="$1"
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

# Show Help (usage)
# ---------------------------------------------------\
if [[ "$FLAG" == "" ]]
	then
	usage
fi

# Variables
# ---------------------------------------------------\
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

# Create VirtualHost
# ---------------------------------------------------\
if [[ "$FLAG" == "1" ]]
	then
	echo -e "Creating $VHOST\nYour mashine IP: $LOCAL_IP\nTry create VirtualHost folder - $DIRECTORY\n"

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

		echo -e "Please add include conf folder into httpd.conf\nIncludeOptional sites-enabled/*.conf\nDirectory $DOMAIN_NAME created\n"
	fi

	# --------------
fi

# Remove VirtualHost
# ---------------------------------------------------\
if [[ "$FLAG" == "2" ]]
	then
	
	if [ -d "$DIRECTORY" ]; then
  	# if exist
  	echo "Removing $VHOST"
  	echo "Remove directory $webroot/$DOMAIN_NAME"
  	/usr/bin/rm -rf $webroot/$DOMAIN_NAME

  	echo "Remove conf file $CONF_FILE"
	/usr/bin/rm -f $CONF_FILE

  	echo "Remove link /etc/httpd/sites-enabled/$CONF_FILE_NAME"
  	/usr/bin/rm -f /etc/httpd/sites-enabled/$CONF_FILE_NAME

  	echo "Comment /etc/hosts param..."
  	/bin/sed -i "s/$LOCAL_IP $DOMAIN_NAME/#$LOCAL_IP $DOMAIN_NAME/" /etc/hosts
  	
  	echo "Done!"

  else
  	echo -e "Directory not exist!\nExit!"
  	exit 1
  fi

fi

