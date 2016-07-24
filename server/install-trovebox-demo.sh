#!/bin/sh

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 curl vim git-core build-essential unzip exiftran mysql-server-5.5 mysql-client-core-5.5 php5 libapache2-mod-php5 php5-curl curl php5-gd php5-mcrypt php5-mysql php-pear php-apc libpcre3-dev
a2enmod rewrite
DEBIAN_FRONTEND=noninteractive apt-get install -y php5-dev php5-imagick
a2enmod deflate
a2enmod expires
a2enmod headers
pecl install oauth-1.2.3
mkdir -p /etc/php5/apache2/conf.d/
echo "extension=oauth.so" >> /etc/php5/apache2/conf.d/oauth.ini
wget https://github.com/photo/frontend/tarball/master -O openphoto.tar.gz
tar -zxvf openphoto.tar.gz > /dev/null 2>&1
mv photo-frontend-* /var/www/openphoto
sudo rm openphoto.tar.gz
mkdir /var/www/openphoto/src/userdata
chown www-data:www-data /var/www/openphoto/src/userdata
mkdir /var/www/openphoto/src/html/assets/cache
chown www-data:www-data /var/www/openphoto/src/html/assets/cache
mkdir /var/www/openphoto/src/html/photos
chown www-data:www-data /var/www/openphoto/src/html/photos
cp /var/www/openphoto/src/configs/openphoto-vhost.conf /etc/apache2/sites-available/openphoto.conf
sed -e "s|\/path\/to\/openphoto\/html\/directory|\/var\/www\/openphoto\/src\/html|g" /var/www/openphoto/src/configs/openphoto-vhost.conf > /etc/apache2/sites-available/openphoto.conf
a2dissite 000-default
a2ensite openphoto
sed -e "s/file_uploads.*/file_uploads = On/g" -e "s/upload_max_filesize.*/upload_max_filesize = 16M/g" -e "s/post_max_size.*/post_max_size = 16M/g" /etc/php5/apache2/php.ini > /etc/php5/apache2/php.ini.tmp
mv /etc/php5/apache2/php.ini.tmp /etc/php5/apache2/php.ini
sudo php5enmod mcrypt
/etc/init.d/apache2 restart
mysql -uroot -e "CREATE DATABASE trovebox"
