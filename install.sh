#!/bin/bash

function updateOrInstall(){
    if [[ $1 == --php ]]; then
        local -n appArray=$2
        for mods in ${appArray[@]}; do
            app="php-${mods}"
            if ! dpkg-query -W $app >/dev/null 2>$1; then
                sudo apt --assume-yes install $app
            else
                printf "${app} already installed, you're good to go\n"
            fi
        done
    else
        local -n appArray=$1
        for app in ${appArray[@]}; do
            if ! dpkg-query -W $app >/dev/null 2>$1; then
                sudo apt --assume-yes install $app
            else
                printf "${app} already installed, you're good to go\n"
            fi
        done
    fi
}

# Get Linux version
# ===============================================================================================
NAME=$(sed -n -e '/NAME/ s/.*= *//p' /etc/os-release)
VERSION_ID=$(sed -n -e '/VERSION_ID/ s/.*= *//p' /etc/os-release)

# Do system update and check essential pacakges and applications
# ===============================================================================================
sudo apt autoclean && sudo apt autoremove && sudo apt update && sudo apt upgrade -y
essentialPackages=("build-essential" "wget" "curl" "git" "unzip" "libgcrypt11-dev" "zlib1g-dev")
updateOrInstall essentialPackages

appPackages=("php" "mariadb-server")
updateOrInstall appPackages


# configuring MySQL/Mariadb Server
# ===============================================================================================
sudo systemctl enable mariadb-server
sudo systemctl restart mariadb-server

sudo mysql_secure_installation

sudo mariadb

CREATE DATABASE nextcloud;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY 'some_secure_password';
FLUSH PRIVILEGES;

# Installing PHP and configuring Apache
# ===============================================================================================
# Required:
# PHP 
# PHP module ctype (included with PHP)
# PHP module curl
# PHP module dom (included with php-xml module)
# PHP module fileinfo (included with PHP)
# PHP module filter (only on Mageia and FreeBSD)
# PHP module GD
# PHP module hash (only on FreeBSD)
# PHP module JSON (included with PHP >= 8.0)
# PHP module libxml (Linux package libxml2 must be >=2.7.0)
# PHP module mbstring
# PHP module openssl (included with PHP >= 8.0)
# PHP module posix (inclued with PHP)
# PHP module session (included with PHP)
# PHP module SimpleXML (included within php-xml module)
# PHP module XMLReader
# PHP module XMLWriter
# PHP module zip
# PHP module zlib (for ubuntu zlib1g-dev should be installed)
# PHP module pdo_sqlite (>=3, usually not recommended for performance reasons)
# PHP module pdo_mysql (MySQL/MariaDB)
# PHP module pdo_pgsql (PostgreSQL)
requires=("cli" "common" "curl" "gd" "json" "mbstring" "zip" "xml" "mysql")

# Recommended packages:
# PHP module bz2 (recommended, required for extraction of apps)
# PHP module intl (increases language translation performance and fixes sorting of non-ASCII characters)
# PHP module sodium (included with PHP>=7.2.0. for Argon2 for password hashing. bcrypt is used as fallback, but if passwords were hashed with Argon2 already and the module is missing, your users can’t log in.)
recommends=("bz2" "intl")

# Required for specific apps:
# PHP module ldap (for LDAP integration)
# PHP module smbclient (SMB/CIFS integration, see SMB/CIFS)
# PHP module ftp (for FTP storage / external user authentication)
# PHP module imap (for external user authentication)
# PHP module bcmath (for passwordless login)
# PHP module gmp (for passwordless login)
# PHP module gmp (for SFTP storage)
# PHP module exif (for image rotation in pictures app)
# PHP module imagick
# avconv or ffmpeg
# OpenOffice or LibreOffice
specifics=("ldap" "smbclient" "imap" "bcmath" "gmp" "imagick")

# For enhanced server performance (optional) select one or more of the following caches:
# PHP module apcu (>= 4.0.6)
# PHP module memcached
# PHP module redis (>= 2.2.6, required for Transactional File Locking)
performances=("php8.2-redis")

updateOrInstall --php requires
updateOrInstall --php recommends
updateOrInstall --php specifics
updateOrInstall performances



sudo a2enmod dir env headers mime rewrite ssl
sudo systemctl restart apache2

sudo phpenmod bcmath gmp imagick intl
sudo systemctl restart apahche2


# Installing Nginx
# ===============================================================================================


# Downloading nextcloud archive file
# ===============================================================================================
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