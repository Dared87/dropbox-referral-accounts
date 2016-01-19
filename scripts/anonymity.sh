#!/bin/bash

echo "Prepare the packages installation"
sudo apt-get update

echo "Add TOR repository"
sudo add-apt-repository "deb http://deb.torproject.org/torproject.org trusty main"
gpg --keyserver keys.gnupg.net --recv 886DDD89 || true
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add - || true
sudo apt-get update

# @see http://stackoverflow.com/questions/11246770/tor-curl-cant-complete-socks5-connection-to-0-0-0-00
echo "Synchronize the virtual machine time to avoid issues with cURL and TOR"
sudo apt-get install -y ntp

echo "Install TOR"
sudo apt-get install -y tor deb.torproject.org-keyring
exit $?
