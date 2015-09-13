#!/bin/bash

echo "Install TOR"
sudo add-apt-repository "deb http://deb.torproject.org/torproject.org trusty main"

gpg --keyserver keyserver.ubuntu.com --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

sudo apt-get update
sudo apt-get install -y deb.torproject.org-keyring tor
