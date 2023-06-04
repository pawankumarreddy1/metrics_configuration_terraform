#!/bin/bash
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.9/bin/apache-tomcat-10.1.9-windows-x64.zip
unzip apache-tomcat-10.1.9-windows-x64.zip
mv apache-tomcat-10.1.9-windows-x64.zip tomcat
cd tomcat
cd bin
./startup.sh