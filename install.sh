#!/bin/bash
###########################################################################################
# Script para instalación de Odoo: OpenERP 7.0 Server on WindowsAzure Ubuntu 14.04 LTS
# 2015 - OSSE - Oficina de Soluciones y Servicios Empresariales
# Author: José Elcorrobarrutia
#------------------------------------------------------------------------------------------
#  
# Este Script instala OpenERP7.0 en una Instancia Nueva de Ubuntu 14.04 LTS de WindowsAzure
# (amd64 20150123) 
# Componentes de la Solución
# Ubuntu 14.04 LTS WindowsAzure
# Apache2
# Postgres9.3
#------------------------------------------------------------------------------------------
# USAGE:
#
# Install-OpenERP7.0
#
# EXAMPLE:
# ./installOpenERP7.0
#
###########################################################################################

#--------------------------------------------------
# Define Variable de Entorno
#--------------------------------------------------
echo -e "\n================================================ Define Enviroment Variables ========================================================="
GLOBAL_HOME="/opt/osse"
OE_HOME="$GLOBAL_HOME/odoo"
ADD_HOME="$GLOBAL_HOME/osseaddons"
OE_USER="osseodoo"
OE_GITREP="https://github.com/OSSESoluciones/osseodoo.git"
OE_GITREPGER="https://github.com/jolevq/geraldo.git"
OE_INSTGER="/usr/local/lib/python2.7/dist-packages/Geraldo-0.4.17-py2.7.egg"
OE_SUPADMPASS="0SS3Soluciones"
OE_CONF="odoo-server"

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n===================================================== Update Server ================================================================"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n================================================= Install PostgreSQL Server ========================================================="
sudo apt-get install postgresql -y
sudo apt-get install postgresql-9.3-postgis-2.1 -y
sudo apt-get install postgresql-contrib -y

echo -e "\n========================================= PostgreSQL $PG_VERSION Settings  =========================================================" #PENDIENTE
# sudo sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = '*'"/g /etc/postgresql/$PG_VERSION/main/postgresql.conf

echo -e "\n---- Creating the Odoo PostgreSQL User  ----"
sudo su - postgres -c "createuser -s --createdb --no-createrole $OE_USER" 2> /dev/null || true 
		
#--------------------------------------------------
# Servidor Web
#--------------------------------------------------
# echo -e "\n========================================================= Install Apache2  ========================================================="
# sudo apt-get install apache2 -y
# sudo apt-get install libapache2-mod-wsgi -y
# sudo a2enmod wsgi

# echo -e "\n======================================= Configure Odoo App With Apache2  ========================================================="
# echo -e "* Create Apache WSGI Server Config file"
# sudo su root -c "echo '<VirtualHost *:8080>' >> /etc/apache2/sites-available/odoo-wsgi.conf"
# sudo su root -c "echo '    ServerName osse.com.pe' >> /etc/apache2/sites-available/odoo-wsgi.conf"

# sudo su root -c "echo '    #ServerAlias *.osse.com.pe' >> /etc/apache2/sites-available/odoo-wsgi.conf"

# sudo su root -c "echo '    WSGIScriptAlias / $OE_HOME/odoo-wsgi.py' >> /etc/apache2/sites-available/odoo-wsgi.conf"
# sudo su root -c "echo '    WSGIDaemonProcess oe user=$OE_USER group=$OE_USER processes=2 python-path=$OE_HOME display-name=apache-odoo' >> /etc/apache2/sites-available/odoo-wsgi.conf"
# sudo su root -c "echo '    WSGIProcessGroup oe' >> /etc/apache2/sites-available/odoo-wsgi.conf"
# sudo su root -c "echo '    ErrorLog /var/log/$OE_USER/odoo-apache2-error.log' >> /etc/apache2/sites-available/odoo-wsgi.conf"
# sudo su root -c "echo '    CustomLog /var/log/$OE_USER/odoo-apache2-access.log combined' >> /etc/apache2/sites-available/odoo-wsgi.conf"
# sudo su root -c "echo '    <Directory $OE_HOME>' >> /etc/apache2/sites-available/odoo-wsgi.conf"
# sudo su root -c "echo '        Require all granted' >> /etc/apache2/sites-available/odoo-wsgi.conf"
# sudo su root -c "echo '    </Directory>' >> /etc/apache2/sites-available/odoo-wsgi.conf"
# sudo su root -c "echo '</VirtualHost>' >> /etc/apache2/sites-available/odoo-wsgi.conf"

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n======================================================== Install Tool Packages ========================================================="
sudo apt-get install git zip wget subversion bzr bzrtools python-pip -y

echo -e "\n---- Install python packages ----"
#20150702 requisitos actualizados
sudo apt-get install python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-mock python-unittest2 python-jinja2 python-pypdf python-gdata python-dev libpq-dev poppler-utils python-pdftools antiword python-setuptools python-decorator python-requests python-passlib python-pil python-gevent python-greenlet python-markupsafe python-qrcode python-six python-wsgiref python-imaging -y

echo -e "\n---- Install python libraries ----"
sudo pip install gdata --upgrade
sudo easy_install Geraldo
sudo mv $OE_INSTGER/geraldo $OE_INSTGER/geraldo.bk
echo -e "\n---- Install wkhtml and place on correct place for ODOO 8 ----"
sudo wget http://http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltopdf/archive/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo cp /usr/local/bin/wkhtmltopdf /usr/bin
sudo cp /usr/local/bin/wkhtmltoimage /usr/bin

echo -e "\n======================================================= Estructura de Archivos ========================================================="
#--------------------------------------------------
# Estructura de Archivos
#--------------------------------------------------
sudo mkdir -p $OE_HOME
sudo mkdir -p $ADD_HOME

echo -e "\n=================================================== Create OpenERP system user ========================================================="
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER

echo -e "\n========================================================= Create Log directory ========================================================="
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n===================================================== Installing Odoo Server ========================================================"
sudo git clone $OE_GITREP --depth 1 --branch 8.0 --single-branch $OE_HOME
sudo git clone $OE_GITREPGER --depth 1 --single-branch $GLOBAL_HOME/geraldo

sudo ln -s $GLOBAL_HOME/geraldo/geraldo $OE_INSTGER/

echo -e "\n---- Requerimientos Branch Odoo ----"
sudo pip install -r $OE_HOME/requirements.txt

sudo chown -R $OE_USER:$OE_USER $GLOBAL_HOME/*
# sudo a2dissite 000-default.conf
# sudo a2ensite odoo-wsgi.conf
# sudo service apache2 restart


	
echo -e "* Create server config file"
sudo cp $OE_HOME/debian/openerp-server.conf /etc/$OE_CONF.conf
sudo chown $OE_USER:$OE_USER /etc/odoo-server.conf
sudo chmod 640 /etc/$OE_CONF.conf

echo -e "* Change server config file"
sudo sed -i s/"db_user = .*"/"db_user = $OE_USER"/g /etc/$OE_CONF.conf
#sudo sed -i s/"; admin_passwd.*"/"admin_passwd = $OE_SUPADMPASS"/g /etc/$OE_CONF.conf
sudo sed -i s/"addons_path"/";addons_path"/g /etc/$OE_CONF.conf
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONF$1.log' >> /etc/$OE_CONF.conf"
sudo su root -c "echo 'addons_path=$OE_HOME/addons,$ADD_HOME' >> /etc/$OE_CONF.conf"

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $ADD_HOME/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME/openerp-server --config=/etc/$OE_CONF.conf' >> $ADD_HOME/start.sh"
sudo chmod 755 $ADD_HOME/start.sh

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

echo -e "* Create init file"
echo '#!/bin/sh' >> ~/$OE_CONF
echo '### BEGIN INIT INFO' >> ~/$OE_CONF
echo '# Provides: $OE_CONF' >> ~/$OE_CONF
echo '# Required-Start: $remote_fs $syslog' >> ~/$OE_CONF
echo '# Required-Stop: $remote_fs $syslog' >> ~/$OE_CONF
echo '# Should-Start: $network' >> ~/$OE_CONF
echo '# Should-Stop: $network' >> ~/$OE_CONF
echo '# Default-Start: 2 3 4 5' >> ~/$OE_CONF
echo '# Default-Stop: 0 1 6' >> ~/$OE_CONF
echo '# Short-Description: Enterprise Business Applications' >> ~/$OE_CONF
echo '# Description: ODOO Business Applications' >> ~/$OE_CONF
echo '### END INIT INFO' >> ~/$OE_CONF
echo 'PATH=/bin:/sbin:/usr/bin' >> ~/$OE_CONF
echo "DAEMON=$OE_HOME/openerp-server" >> ~/$OE_CONF
echo "NAME=$OE_CONF" >> ~/$OE_CONF
echo "DESC=$OE_CONF" >> ~/$OE_CONF
echo '' >> ~/$OE_CONF
echo '# Specify the user name (Default: odoo).' >> ~/$OE_CONF
echo "USER=$OE_USER" >> ~/$OE_CONF
echo '' >> ~/$OE_CONF
echo '# Specify an alternate config file (Default: /etc/$OE_CONF.conf).' >> ~/$OE_CONF
echo "CONFIGFILE=\"/etc/$OE_CONF.conf\"" >> ~/$OE_CONF
echo '' >> ~/$OE_CONF
echo '# pidfile' >> ~/$OE_CONF
echo 'PIDFILE=/var/run/$NAME.pid' >> ~/$OE_CONF
echo '' >> ~/$OE_CONF
echo '# Additional options that are passed to the Daemon.' >> ~/$OE_CONF
echo 'DAEMON_OPTS="-c $CONFIGFILE"' >> ~/$OE_CONF
echo '[ -x $DAEMON ] || exit 0' >> ~/$OE_CONF
echo '[ -f $CONFIGFILE ] || exit 0' >> ~/$OE_CONF
echo 'checkpid() {' >> ~/$OE_CONF
echo '[ -f $PIDFILE ] || return 1' >> ~/$OE_CONF
echo 'pid=`cat $PIDFILE`' >> ~/$OE_CONF
echo '[ -d /proc/$pid ] && return 0' >> ~/$OE_CONF
echo 'return 1' >> ~/$OE_CONF
echo '}' >> ~/$OE_CONF
echo '' >> ~/$OE_CONF
echo 'case "${1}" in' >> ~/$OE_CONF
echo 'start)' >> ~/$OE_CONF
echo 'echo -n "Starting ${DESC}: "' >> ~/$OE_CONF
echo 'start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONF
echo '--chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONF
echo '--exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE_CONF
echo 'echo "${NAME}."' >> ~/$OE_CONF
echo ';;' >> ~/$OE_CONF
echo 'stop)' >> ~/$OE_CONF
echo 'echo -n "Stopping ${DESC}: "' >> ~/$OE_CONF
echo 'start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONF
echo '--oknodo' >> ~/$OE_CONF
echo 'echo "${NAME}."' >> ~/$OE_CONF
echo ';;' >> ~/$OE_CONF
echo '' >> ~/$OE_CONF
echo 'restart|force-reload)' >> ~/$OE_CONF
echo 'echo -n "Restarting ${DESC}: "' >> ~/$OE_CONF
echo 'start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONF
echo '--oknodo' >> ~/$OE_CONF
echo 'sleep 1' >> ~/$OE_CONF
echo 'start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONF
echo '--chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONF
echo '--exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE_CONF
echo 'echo "${NAME}."' >> ~/$OE_CONF
echo ';;' >> ~/$OE_CONF
echo '*)' >> ~/$OE_CONF
echo 'N=/etc/init.d/${NAME}' >> ~/$OE_CONF
echo 'echo "Usage: ${NAME} {start|stop|restart|force-reload}" >&2' >> ~/$OE_CONF
echo 'exit 1' >> ~/$OE_CONF
echo ';;' >> ~/$OE_CONF
echo '' >> ~/$OE_CONF
echo 'esac' >> ~/$OE_CONF
echo 'exit 0' >> ~/$OE_CONF

echo -e "* Security Init File"
sudo mv ~/$OE_CONF /etc/init.d/$OE_CONF
sudo chmod 755 /etc/init.d/$OE_CONF
sudo chown root: /etc/init.d/$OE_CONF

echo -e "* Start ODOO on Startup"
sudo update-rc.d $OE_CONF defaults
 
sudo service $OE_CONF start
echo "Done! The ODOO server can be started with: service odoo-server start"
