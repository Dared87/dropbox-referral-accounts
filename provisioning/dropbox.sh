#!/bin/bash

echo "Install Dropbox daemon"
cp -v /vagrant/provisioning/resources/dropbox.tar.gz ${HOME}/dropbox.tar.gz
tar xzf ${HOME}/dropbox.tar.gz -C ${HOME}

# Clean-up previous Dropbox daemon
PROCESS=$(ps aux | grep '[d]ropbox-dist' | awk '{print $2}')
if [ ! -z "${PROCESS}" ] ; then
    echo "Kill existing daemon process"
    kill ${PROCESS}
fi

if [ -f ${HOME}/dropbox.log ] ; then
    echo "Clean-up existing Dropbox daemon logs"
    rm -f ${HOME}/dropbox.log
fi
