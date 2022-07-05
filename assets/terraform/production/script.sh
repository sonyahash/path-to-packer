#!/bin/bash

sudo cd /etc/nginx/sites-enabled 
sudo unlink default
sudo cd ../

sudo cd /var/www/

sudo mv /tmp/index.html /var/www/
sudo mv /tmp/logo.png /var/www/html
sudo mv /tmp/under-construction.gif /var/www/html

sudo systemctl reload nginx 