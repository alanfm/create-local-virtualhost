#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-admin.kz


# iptable rules
# iptables -I INPUT -p tcp -m tcp --dport 81 -j ACCEPT
# service iptables save
# service iptables restart

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
   -l      List VirtualHost

Example:
$0 -c vhost
$0 -r vhost
$0 -l show
   
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
	-l|--list)
	FLAG="3"
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

CHOWNERS="root:webadmins"
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
  		echo -e "Create: $DIRECTORY"
	  	/bin/mkdir -p $DIRECTORY

	  	echo "Create $INDEX_HTML"
	  	/bin/touch $INDEX_HTML

	  	echo "<html>" > $INDEX_HTML
		echo " <head>" >> $INDEX_HTML
		echo "    <title>$DOMAIN_NAME</title>" >> $INDEX_HTML
		echo " </head>" >> $INDEX_HTML
		echo " <body>" >> $INDEX_HTML
		echo "    <h1>$DOMAIN_NAME working!</h1>" >> $INDEX_HTML
		echo " </body>" >> $INDEX_HTML
		echo "</html>" >> $INDEX_HTML
		echo -e "File $INDEX_HTML created"

		echo "Change vhost folder permission..."
		/bin/chown -R $CHOWNERS $webroot/$DOMAIN_NAME
		/bin/chmod -R 775 $webroot/$DOMAIN_NAME

		echo "Create httpd service folders..."
		/bin/mkdir -p /etc/httpd/sites-created
		/bin/mkdir -p /etc/httpd/sites-enabled

		echo "Create conf file $CONF_FILE"
		/bin/touch $CONF_FILE

		echo "<VirtualHost *:80>" > $CONF_FILE
		echo "ServerName www.$DOMAIN_NAME" >> $CONF_FILE
		echo "ServerAlias $DOMAIN_NAME" >> $CONF_FILE
		echo "DocumentRoot /var/www/$DOMAIN_NAME/public_html" >> $CONF_FILE
		echo "ErrorLog /var/www/$DOMAIN_NAME/error.log" >> $CONF_FILE
		echo "CustomLog /var/www/$DOMAIN_NAME/requests.log combined" >> $CONF_FILE
		echo "<Directory /var/www/$DOMAIN_NAME/public_html>" >> $CONF_FILE
		echo "AllowOverride All" >> $CONF_FILE
		echo "</Directory>" >> $CONF_FILE
		echo "</VirtualHost>" >> $CONF_FILE

		echo "Create link / Enable domain $DOMAIN_NAME"
		/bin/ln -s $CONF_FILE /etc/httpd/sites-enabled/$CONF_FILE_NAME

		echo -e "Update /etc/hosts file\nAdd $LOCAL_IP $DOMAIN_NAME"
		echo "$LOCAL_IP $DOMAIN_NAME" >> /etc/hosts

		echo "Restart HTTPD..."
		service httpd restart

		echo -e "\nDone!\n\nPlease add include conf folder into httpd.conf parameter:\nIncludeOptional sites-enabled/*.conf\n"
	fi

	# --------------
fi

# Remove VirtualHost
# ---------------------------------------------------\
if [[ "$FLAG" == "2" ]]
	then
	
	if [ -d "$DIRECTORY" ]; then
  	# if exist
  	echo -e "\nRemoving $VHOST"

  	echo "Remove directory $webroot/$DOMAIN_NAME"
  	/bin/rm -rf $webroot/$DOMAIN_NAME

  	echo "Remove conf file $CONF_FILE"
	/bin/rm -f $CONF_FILE

  	echo "Remove link /etc/httpd/sites-enabled/$CONF_FILE_NAME"
  	/bin/rm -f /etc/httpd/sites-enabled/$CONF_FILE_NAME

  	echo "Comment /etc/hosts param..."
  	/bin/sed -i "s/$LOCAL_IP $DOMAIN_NAME/#$LOCAL_IP $DOMAIN_NAME/" /etc/hosts
  	
  	echo -e "Done!\n"

  else
  	echo -e "\nDirectory not exist!\nPlease use remove command without extention\nExit!\n"
  	exit 1
  fi

fi

# See VHosts
# ---------------------------------------------------\
if [[ "$FLAG" == "3" ]]
	then
	echo -e "\nSites created"
	/bin/ls -la /etc/httpd/sites-created

	echo -e "\nSites enabled"
	/bin/ls -la /etc/httpd/sites-enabled

	echo -e "\n/var/www folder list"
	/bin/ls -la /var/www
fi
