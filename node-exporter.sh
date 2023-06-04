#!/bin/bash
yum install httpd -y
Systemctl start httpd
systemctl enable httpd
systemctl status httpd
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0-rc.0/node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
tar -zvxf node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
mv node_exporter-1.4.0-rc.0.linux-amd64/ node_exporter
cp -r * /opt 
cd /opt
cd node_exporter
nohup ./node_exporter &
cd
cd /tmp
curl -s https://api.github.com/repos/Lusitaniae/apache_exporter/releases/latest|grep browser_download_url|grep linux-amd64|cut -d '"' -f 4|wget -qi -
tar -xvzf apache_exporter-0.13.3.linux-amd64.tar.gz
rm -rf apache_exporter-0.13.3.linux-amd64.tar.gz
mv  apache_exporter-0.13.3.linux-amd64/ apache_exporter
cp -r * /opt
cd /opt
cd apache_exporter
nohup ./apache_exporter &