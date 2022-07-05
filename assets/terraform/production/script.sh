#!/bin/bash

sudo cd /etc/nginx/sites-enabled 
sudo unlink default
sudo cd ../

sudo cd /var/www/

sudo mv /tmp/index.html /var/www/html/

sudo systemctl reload nginx 