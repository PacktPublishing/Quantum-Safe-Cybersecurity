#!/bin/sh
#
curl -L -o age-linux-amd64.tar.gz "https://dl.filippo.io/age/latest?for=linux/amd64"
tar -xzf age-linux-amd64.tar.gz
sudo cp age/age* /usr/local/bin/
age --version
