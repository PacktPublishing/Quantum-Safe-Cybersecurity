#!/bin/sh
#
curl -L -o age-mac-arm64.tar.gz "https://dl.filippo.io/age/latest?for=darwin/arm64"
tar -xzf age-mac-arm64.tar.gz
sudo cp age/age* /usr/local/bin/
age --version
