#!/bin/bash

apt-get -y install sendmail
apt-get -y install smokeping
sudo a2enmod cgi
service apache2 restart
