# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8080

	#config.vm.provision "shell", path: "provision.sh"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.56.101"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 curl vim git-core build-essential exiftran mysql-server-5.5 mysql-client-core-5.5 php5 libapache2-mod-php5 php5-curl curl php5-gd php5-mcrypt php5-mysql php-pear php-apc libpcre3-dev
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
    sed -e "s|\/path\/to\/openphoto\/html\/directory|\/var\/www\/openphoto\/src\/html|g" -e "s/yourdomainname.com/trovebox.dev/g" /var/www/openphoto/src/configs/openphoto-vhost.conf > /etc/apache2/sites-available/openphoto.conf
    a2dissite 000-default
    a2ensite openphoto
    sed -e "s/file_uploads.*/file_uploads = On/g" -e "s/upload_max_filesize.*/upload_max_filesize = 16M/g" -e "s/post_max_size.*/post_max_size = 16M/g" /etc/php5/apache2/php.ini > /etc/php5/apache2/php.ini.tmp
    mv /etc/php5/apache2/php.ini.tmp /etc/php5/apache2/php.ini
    sudo php5enmod mcrypt
    /etc/init.d/apache2 restart
    mysql -uroot -e "CREATE DATABASE trovebox"
  SHELL
end
