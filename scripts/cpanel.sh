#!/bin/bash
set -e

hostname cpanel.simplecloud.club
echo "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf

cd /home
yum install wget
wget -N http://httpupdate.cpanel.net/latest
sh latest
