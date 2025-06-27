#!/bin/bash
sudo su -
yum install httpd -y
systemctl start httpd
systemctl enable httpd
systemctl status httpd
echo "<h1>Welcome to VPC Peering Demo HELLO FROM PVT INSTANCE OF VPC2 </h1>" > /var/www/html/index.html
echo "<p>Instance in VPC B</p>" >> /var/www/html/index.html
