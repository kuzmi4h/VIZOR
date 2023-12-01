#!/bin/bash

# Set the API token and chat ID for Telegram
API_TOKEN="<your_api_token>"
CHAT_ID="<your_chat_id>"

# Set the flag file name
FLAG_FILE=".done"

# Check if the flag file exists
if [ -f "$FLAG_FILE" ]; then
  # If yes, exit the script
  echo "The script has already been executed."
  exit 0
fi

# Update the package list and install the dependencies
sudo dnf update -y
sudo dnf install -y httpd mariadb-server php php-mysqlnd php-fpm nginx

# Download and extract Wordpress
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
sudo mv wordpress /var/www/html

# Create a database and a user for Wordpress
sudo systemctl start mariadb
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configure Wordpress
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo sed -i "s/database_name_here/wordpress/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/wordpress/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/password/" /var/www/html/wordpress/wp-config.php

# Configure Apache2
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
sudo sed -i "s/Listen 80/Listen 8080/" /etc/httpd/conf/httpd.conf
sudo systemctl start httpd

# Configure Nginx
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo curl -o /etc/nginx/nginx.conf [1](https://stackoverflow.com/questions/48524045/send-command-from-bash-script-to-telegram-cli) # Get the nginx.conf template from GIT or other source
sudo systemctl start nginx

# Send a notification to Telegram
MESSAGE="The script has been executed successfully."
curl -s -X POST https://api.telegram.org/bot$API_TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"

# Create the flag file
touch "$FLAG_FILE"
