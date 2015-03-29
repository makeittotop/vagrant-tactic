#!/usr/bin/env bash

# Install epel repo
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

yum -y update

# Install guest additions
# On host os, vagrant plugin install vagrant-vbguest
yum -y install gcc kernel-devel make

# Install apache httpd
rpm -qa | grep httpd &> /dev/null || {
  yum -y install httpd
}

# Check if the apache server is running
service httpd status &> /dev/null || {
  service httpd start;
  chkconfig httpd on;
}

# Install postgresql latest
rpm -qa | grep postgres &> /dev/null || {
  yum install -y http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm;
  yum install -y postgresql94-server postgresql94-contrib;
}

# Check if the postgres db is running
service postgresql-9.4 status &> /dev/null || {
  service postgresql-9.4 initdb
  service postgresql-9.4 start;
  chkconfig postgresql-9.4 on;
}

# Install python-devel 
yum -y install gcc zlib-devel libxslt-devel libxml2-devel python-devel python-pip.noarch

