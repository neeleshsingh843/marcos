#!/bin/bash
sudo su -
yum install httpd -y
systemctl start httpd
systemctl enable httpd
systemctl status httpd
echo "<h1>Welcome to VPC Peering Demo HELLO FROM INSTANCE 1</h1>" > /var/www/html/index.html
echo "<p>Instance in VPC A</p>" >> /var/www/html/index.html
