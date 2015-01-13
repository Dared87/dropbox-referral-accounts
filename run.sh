#!/bin/bash
function create_box() {
    local LIBRARIES_FOLDER=$1
    local ACCOUNT_ID=$2

    echo "Destroy any previously running Vagrant box..."
    vagrant destroy -f

    echo "Generate MAC address..."
    MAC_ADDRESS=$(od /dev/urandom -w6 -tx1 -An | sed -e 's/ //g' | head -n 1 | awk '{print toupper($0)}')

    echo "Create box for account ${ACCOUNT_ID} with MAC address ${MAC_ADDRESS}..."
    ACCOUNT_ID=${ACCOUNT_ID} MAC_ADDRESS=${MAC_ADDRESS} vagrant up --provision

    return $?
}

LIBRARIES_FOLDER="$(pwd)/libs"

echo "Read configuration file"
source ${LIBRARIES_FOLDER}/ini-parser.sh
read_ini "config/config.ini" "config"

if [ -z "$1" ] ; then
    RANGE=1
elif [ ! -z "$2" ] ; then
    RANGE=$(seq $1 $2)
else
    RANGE=$1
fi

echo "Loop over range"
for ACCOUNT_ID in ${RANGE}
do
    until create_box ${LIBRARIES_FOLDER} ${ACCOUNT_ID}
    do
        echo "Box creation failed... Let's try again."
    done
done

echo "Destroy the last running box..."
vagrant destroy -f
