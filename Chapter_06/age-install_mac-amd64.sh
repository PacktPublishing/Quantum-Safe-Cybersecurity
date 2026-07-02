#!/bin/sh
#
curl -L -o age-mac-amd64.tar.gz "https://dl.filippo.io/age/latest?for=darwin/amd64"
tar -xzf age-mac-amd64.tar.gz
sudo cp age/age* /usr/local/bin/
age --version
