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

