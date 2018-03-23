echo
echo "Installing CKAN from package"

echo
echo "- Set locale"
locale-gen
export LC_ALL="en_GB.UTF-8"
sudo locale-gen en_GB.UTF-8

echo
echo "1. Install the CKAN package"
echo "- Update Ubuntu's package index"
sudo apt update
sudo apt-mark hold grub*
sudo apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" dist-upgrade

echo
echo "- Install the Ubuntu packages that CKAN requires"
sudo apt install -y nginx apache2 libapache2-mod-wsgi libpq5 redis-server git-core
# Apache needs to be stopped for nginx to run
sudo service apache2 stop
# nginx is a dependency of ckan
sudo service nginx start

echo
echo "- Enable wsgi module for apache"
sudo a2enmod wsgi

echo
echo "- Configuring packages"
sudo dpkg --configure -a

echo
echo "- Download the CKAN package"
wget -q http://packaging.ckan.org.s3-eu-west-1.amazonaws.com/python-ckan_2.7-xenial_amd64.deb

echo
echo "- Install the CKAN package"
sudo dpkg -i python-ckan_2.7-xenial_amd64.deb

echo
echo "- Configuring packages"
sudo dpkg --configure -a

echo
echo "2. Install and configure PostgreSQL"
echo "- Install PostgreSQL"
sudo apt install -y postgresql

echo
echo "- Create a database user"
sudo -u postgres createuser -S -D -R ckan_default
sudo -u postgres psql -c "ALTER USER ckan_default with password 'pass'"

echo
echo "- Create ckan database"
sudo -u postgres createdb -O ckan_default ckan_default -E utf-8

echo
echo "3. Install and configure Solr"
echo "- Install Solr"
sudo apt install -y solr-jetty

echo "- Edit Jetty configuration"
sudo cp /vagrant/vagrant/jetty /etc/default/jetty8
sudo service jetty8 restart

echo
echo "- Replace the default schema.xml file with a symlink to the CKAN schema"
sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml
sudo service jetty8 restart

echo
echo "4. Update the configuration and initialize the database"
echo "- Edit the CKAN configuration file"
sudo cp /vagrant/vagrant/package_production.ini /etc/ckan/default/production.ini

echo "- Initialize your CKAN database"
sudo ckan db init

echo "- Enable filestore with local storage"
sudo mkdir -p /var/lib/ckan/default
sudo chown www-data /var/lib/ckan/default
sudo chmod u+rwx /var/lib/ckan/default

echo
echo "- Create an admin user"
source /usr/lib/ckan/default/bin/activate
cd /usr/lib/ckan/default/src/ckan
paster --plugin=ckan user add admin email=admin@email.org password=pass -c /etc/ckan/default/production.ini
paster --plugin=ckan sysadmin add admin -c /etc/ckan/default/production.ini

echo
echo "- 5. Restart services"
sudo service apache2 restart
sudo service nginx restart

echo
echo "- 6. Adding initial test data to CKAN"
cd /usr/lib/ckan/default/src/ckan
source ../../bin/activate
paster create-test-data -c /etc/ckan/default/production.ini
paster create-test-data search -c /etc/ckan/default/production.ini
paster create-test-data gov -c /etc/ckan/default/production.ini
paster create-test-data family -c /etc/ckan/default/production.ini
paster create-test-data vocabs -c /etc/ckan/default/production.ini
paster create-test-data hierarchy -c /etc/ckan/default/production.ini

echo
echo "Open http://192.168.19.80/ in your web browser"
echo "Login: testsysadmin/testsysadmin"
