# Update system
sudo apt autoclean && sudo apt autoremove && sudo apt update && sudo apt upgrade -y


# Installing and configuring MySQL Server
sudo apt install mariadb-server -y
sudo systemctl enable mariadb-server
sudo systemctl restart mariadb-server

sudo mysql_secure_installation

sudo mariadb

CREATE DATABASE nextcloud;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY 'some_secure_password';
FLUSH PRIVILEGES;

# Installing PHP and configuring Apache
sudo apt install -y php php-apcu php-bcmath \
    php-cli php-common php-curl php-dg php-gmp \
    php-imagick php-intl php-mbstring php-mysql \
    php-zip php-xml

sudo a2enmod dir env headers mime rewrite ssl
sudo systemctl restart apache2

sudo phpenmod bcmath gmp imagick intl
sudo systemctl restart apahche2


# Installing Nginx

# Downloading nextcloud archive file
NEXTCLOUD_URL="https://download.nextcloud.com/server/releases/latest.zip"
wget NEXTCLOUD_URL

unzip latest.zip
mv nextcloud vod.htez.com
sudo chown -R www-data:www-data vod.htez.com
sudo mv vod.htez.com /var/www/

sudo a2dissite 000-default.conf
sudo systemctl restart apache2

touch /etc/apache2/sites-available/vod.htez.com.conf

<VirtualHost *:80>
    DocumentRoot "/var/www/vod.htez.com"
    ServerName vod.htez.com

    <Directory "/var/www/vod.htez.com/">
        Options MultiViews FollowSymlinks
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>

    TransferLog /var/log/apache2/vod.htez.com_access.log
    ErrorLog /var/log/apache2/vod.htez.com_error.log
</VirtualHost>

sudo a2ensite vod.htez.com.conf
sudo systemctl restart apache2