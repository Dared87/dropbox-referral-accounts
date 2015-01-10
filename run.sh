#!/bin/bash

echo "Read configuration file"
source libs/ini-parser.sh
read_ini "config/config.ini" "config"

START=$INI__config__partnerAccountIdStart
STOP=$INI__config__partnerAccountIdStop

echo "Destroy any previously running Vagrant box."
vagrant destroy -f

echo "Loop over defined partner accounts ID range"
for ACCOUNT_ID in $(seq ${START} ${STOP})
do
    echo "Create box for account ${ACCOUNT_ID}..."
    ACCOUNT_ID=${ACCOUNT_ID} vagrant up --provision

    echo "Destroy the box for account ${ACCOUNT_ID}..."
    vagrant destroy -f
done
