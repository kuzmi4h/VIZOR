#!/bin/bash

set -e

# Set the API token and chat ID for Telegram
API_TOKEN="*"
CHAT_ID="*"
MESSAGE="Скрипт успешно завершил работу. Стек развернут на AlmaLinux 8."

# Set the flag file name
FLAG_FILE=".done"

# Set the Wordpress variables
WP_DATABASE="wordpress"
WP_USER="wpuser"
WP_PASS="wppass"

# Check if the flag file exists
if [ -f "$FLAG_FILE" ]; then
  # If yes, exit the script
  echo "The script has already been executed."
  exit 0
fi

# Update the package list and install the dependencies
sudo dnf update -y
sudo dnf install -y httpd mariadb-server nginx wget tar curl

sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf config-manager --enable remi
sudo dnf -y update
sudo dnf install -y php83-php php83-php-mysqlnd
sudo systemctl enable php83-php-fpm
sudo systemctl start php83-php-fpm



# Download and extract Wordpress
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
sudo cp -r wordpress/ /var/www/html/

# Create a database and a user for Wordpress
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER '$WP_USER'@'localhost' IDENTIFIED BY '$WP_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO '$WP_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configure Wordpress
wget https://raw.githubusercontent.com/kuzmi4h/VIZOR/main/wp-config.php
sudo cp ./wp-config.php /var/www/html/wp-config.php


# Configure Apache2
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
wget https://raw.githubusercontent.com/kuzmi4h/VIZOR/main/httpd.conf
sudo cp ./httpd.conf /etc/httpd/conf/httpd.conf
sudo chown -R apache:apache /var/www/html/*
sudo chmod -R 755 /var/www/html/*
sudo systemctl start httpd
sudo systemctl enable httpd

# Configure Nginx
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
wget https://raw.githubusercontent.com/kuzmi4h/VIZOR/main/nginx.conf
sudo cp ./nginx.conf /etc/nginx/nginx.conf
sudo systemctl start nginx
sudo systemctl enable nginx

# Start php-fpm
sudo systemctl start php83-php-fpm
sudo systemctl enable php83-php-fpm

# Configure firewalld
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --reload

# Configure selinux
setsebool -P httpd_can_network_connect 1

# Send a notification to Telegram
MESSAGE="The script has been executed successfully."
curl -s -X POST https://api.telegram.org/bot$API_TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"

# Create the flag file
touch "$FLAG_FILE"
