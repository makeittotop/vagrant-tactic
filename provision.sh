#!/usr/bin/env bash

yum -y update

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


