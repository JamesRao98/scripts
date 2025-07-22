#!/bin/bash

# Exit on error
set -e

# Prompt for database details
read -p "Enter WordPress database name: " WP_DB_NAME
read -p "Enter WordPress database user: " WP_DB_USER
read -s -p "Enter WordPress database password: " WP_DB_PASS

echo

# Update system
sudo apt update && sudo apt upgrade -y

# Install Apache, MariaDB, PHP, and required extensions
sudo apt install -y apache2 mariadb-server php php-mysql libapache2-mod-php php-cli php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip wget unzip

# Enable Apache mods and restart
sudo a2enmod rewrite
sudo systemctl restart apache2

# Secure MariaDB installation (optional, interactive)
echo "Securing MariaDB installation..."
sudo mysql_secure_installation

# Create WordPress database and user
sudo mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \`$WP_DB_NAME\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASS';
GRANT ALL PRIVILEGES ON \`$WP_DB_NAME\`.* TO '$WP_DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Database and user created."

# Download and extract WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
rm -rf wordpress
 tar -xzf latest.tar.gz
sudo rm -rf /var/www/html/*
sudo cp -r wordpress/* /var/www/html/

# Set permissions
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 755 {} \;
sudo find /var/www/html/ -type f -exec chmod 644 {} \;

# Configure wp-config.php
cd /var/www/html
if [ ! -f wp-config.php ]; then
    sudo cp wp-config-sample.php wp-config.php
    sudo sed -i "s/database_name_here/$WP_DB_NAME/" wp-config.php
    sudo sed -i "s/username_here/$WP_DB_USER/" wp-config.php
    sudo sed -i "s/password_here/$WP_DB_PASS/" wp-config.php
fi

# Generate and set WordPress salts
SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
sudo sed -i "/AUTH_KEY/d" wp-config.php
sudo sed -i "/SECURE_AUTH_KEY/d" wp-config.php
sudo sed -i "/LOGGED_IN_KEY/d" wp-config.php
sudo sed -i "/NONCE_KEY/d" wp-config.php
sudo sed -i "/AUTH_SALT/d" wp-config.php
sudo sed -i "/SECURE_AUTH_SALT/d" wp-config.php
sudo sed -i "/LOGGED_IN_SALT/d" wp-config.php
sudo sed -i "/NONCE_SALT/d" wp-config.php
echo "$SALT" | sudo tee -a wp-config.php > /dev/null

echo "WordPress installation complete! Visit your server's IP to finish setup."
