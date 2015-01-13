#!/bin/bash
#
# Generate a MAC Address that can be used by VirtualBox.
# See https://www.virtualbox.org/ticket/10778 for more information.
#
function generate_mac_address_for_virtualbox() {
    local FIRST_CHAR=$(cat /dev/urandom | tr -dc 0-9A-Fa-f | head -c1)
    local SECOND_CHAR=$(cat /dev/urandom | tr -dc 02468ACEace | head -c1)
    local FOLLOWING_CHARS=$(cat /dev/urandom | tr -dc 0-9A-Fa-f | head -c10)

    echo "${FIRST_CHAR}${SECOND_CHAR}${FOLLOWING_CHARS}"
}
function create_box() {
    local LIBRARIES_FOLDER=$1
    local ACCOUNT_ID=$2
    local MAC_ADDRESS=$(generate_mac_address_for_virtualbox)

    echo "Destroy any previously running Vagrant box..."
    vagrant destroy -f

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

exit 0
