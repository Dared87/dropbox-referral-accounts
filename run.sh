#!/bin/bash
#
# Generate a MAC Address that can be used by VirtualBox.
# See https://www.virtualbox.org/ticket/10778 for more information.
#
function generate_mac_address_for_virtualbox() {
    local FIRST_CHAR=$(LC_CTYPE=C tr -dc 0-9A-Fa-f < /dev/urandom | head -c1)
    local SECOND_CHAR=$(LC_CTYPE=C tr -dc 02468ACEace < /dev/urandom | head -c1)
    local FOLLOWING_CHARS=$(LC_CTYPE=C tr -dc 0-9A-Fa-f < /dev/urandom | head -c10)

    echo "${FIRST_CHAR}${SECOND_CHAR}${FOLLOWING_CHARS}" | tr a-z A-Z
}

function create_box() {
    local ACCOUNT_ID=$1
    local MAC_ADDRESS=$(generate_mac_address_for_virtualbox)

    echo "Create a temporary Vagrant box #${ACCOUNT_ID} with the MAC address ${MAC_ADDRESS}..."
    ACCOUNT_ID=${ACCOUNT_ID} MAC_ADDRESS=${MAC_ADDRESS} vagrant up --provision

    return $?
}

function destroy_box() {
    if [ ! -z "$1" ] ; then
        echo "Destroy the temporary Vagrant box #$1..."
    else
        echo "Destroy any previously created Vagrant box..."
    fi

    vagrant destroy -f

    return $?
}

# No argument provided, default to 1
if [ -z "$1" ] ; then
    RANGE=1
# Two arguments provided, create a range
elif [ ! -z "$2" ] ; then
    RANGE=$(seq $1 $2)
# One argument provided, use it
else
    RANGE=$1
fi

destroy_box

for ACCOUNT_ID in ${RANGE}
do
    if create_box ${ACCOUNT_ID} ; then
        destroy_box ${ACCOUNT_ID}
    fi
done

exit 0
