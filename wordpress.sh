#!/bin/bash

# Set the API token and chat ID for Telegram
API_TOKEN="846485825:AAFkWzlS4g1z97bbAn_4LhbH0bJy81TU-w4"
CHAT_ID="362655759"

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
sudo dnf install -y httpd mariadb-server nginx wget tar curl
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf module reset -y php
sudo dnf module install -y php:remi-8.3


# Download and extract Wordpress
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/

# Create a database and a user for Wordpress
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wppass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
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
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# Configure firewalld
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

# Send a notification to Telegram
MESSAGE="The script has been executed successfully."
curl -s -X POST https://api.telegram.org/bot$API_TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="Скрипт успешно завершил работу. Стек развернут на AlmaLinux 8."

# Create the flag file
touch "$FLAG_FILE"
