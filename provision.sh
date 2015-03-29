#!/usr/bin/env bash

# Install epel repo
rpm -qa | grep epel &> /dev/null || { 
  rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm;
}

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

# Install python modules
python -c "import lxml" &> /dev/null || pip install lxml  # PIL pycrypto psycopg2 

python -c "import PIL" &> /dev/null || pip install PIL  # PIL pycrypto psycopg2

python -c "import pycrypto" &> /dev/null || pip install pycrypto  # PIL pycrypto psycopg2 

python -c "import psycopg2" &> /dev/null || {
  export PATH="/usr/pgsql-9.4/bin/:$PATH";
  yum install -y libpqxx-devel.x86_64;
  pip install psycopg2  # PIL pycrypto psycopg2
}

# Download TACTIC
stat ./TACTIC-4.3.0.v01.zip &> /dev/null || wget -O ./TACTIC-4.3.0.v01.zip http://community.southpawtech.com/sites/default/files/download/TACTIC%20-%20Enterprise/TACTIC-4.3.0.v01.zip
unzip ./TACTIC-4.3.0.v01.zip &> /dev/null || yum -y install unzip

# Configure postgres

md5sum ./TACTIC-4.3.0.v01/src/install/postgresql/pg_hba.conf /var/lib/pgsql/9.4/data/pg_hba.conf | awk '{ print $1; }' | 
for arg in `xargs`; 
  do 
    if [ -z $first_arg ]; 
      then first_arg=$arg; 
    else 
      if [ "$first_arg" == "$arg" ]; 
        then echo "files match"; 
      else 
        echo "files don't match";

        service postgresql-9.4 stop;
        mv /var/lib/pgsql/9.4/data/pg_hba.conf /var/lib/pgsql/9.4/data/pg_hba.conf.INSTALL;
        cp ./TACTIC-4.3.0.v01/src/install/postgresql/pg_hba.conf /var/lib/pgsql/9.4/data/pg_hba.conf;
        chown postgres:postgres /var/lib/pgsql/9.4/data/pg_hba.conf;
        service postgresql-9.4 start;
        psql -U postgres template1;
      fi; 
    fi; 
  done


# Install TACTIC
stat /home/apache/tactic &> /dev/null || yes | python /home/vagrant/TACTIC-4.3.0.v01/src/install/install.py --defaults

# Copy the tactic virtualhost file over to httpd conf.d/
stat /etc/httpd/conf.d/tactic.conf &> /dev/null || cp /home/apache/tactic_data/config/tactic.conf /etc/httpd/conf.d/tactic.conf;
stat /var/www/html/index.html &> /dev/null || echo '<META http-equiv="refresh" content="0;URL=/tactic">' > /var/www/html/index.html;

# Restart apache service just in case
service httpd restart

# Start tactic in DEV mode 
#su apache -s /bin/bash -c "python /home/apache/tactic/src/bin/startup_dev.py &"

# Start TACTIC as a service
service tactic status &> /dev/null || {
  cp /home/apache/tactic/src/install/service/tactic /etc/init.d/tactic
  chmod 755 /etc/init.d/tactic
  /sbin/chkconfig tactic on
  /etc/init.d/tactic start
}

