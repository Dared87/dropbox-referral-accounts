#!/bin/bash

# List of email Providers for email generation
EMAIL_PROVIDERS=("aol.com" "att.net" "comcast.net" "facebook.com" "gmail.com" "gmx.com" "googlemail.com" "google.com" "hotmail.com" "hotmail.co.uk" "mac.com" "me.com" "mail.com" "msn.com" "live.com" "sbcglobal.net" "verizon.net" "yahoo.com" "yahoo.co.uk" "gmx.de" "hotmail.de" "live.de" "online.de" "t-online.de" "web.de" "yahoo.de")

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

    source config/config.cfg
	
	local RESP=$(curl -s "http://api.randomuser.me/?inc=email,name&nat=${location}&format=csv&noinfo" | sed -n '2p')
	local FIRST=$(echo $RESP | cut -d',' -f 2)
	local LAST=$(echo $RESP | cut -d',' -f 3)
	local EMAIL=$(echo $RESP | cut -d',' -f 4)
	local EMAIL_STRIPPED=$(echo $EMAIL | cut -d'@' -f 1)
	local RANDOM_NUMBER=$(( ( RANDOM % 100 )  + 1 ))
	local RANDOM_PROVIDER=${EMAIL_PROVIDERS[$RANDOM % ${#EMAIL_PROVIDERS[@]}]}
	local EMAIL_NEW="${EMAIL_STRIPPED}${RANDOM_NUMBER}@${RANDOM_PROVIDER}"
	
    echo "Create a temporary Vagrant box #${ACCOUNT_ID} with the MAC address ${MAC_ADDRESS}..."
    ACCOUNT_ID=${ACCOUNT_ID} EMAIL=${EMAIL_NEW} FIRST=${FIRST} LAST=${LAST} MAC_ADDRESS=${MAC_ADDRESS} vagrant up --provision --provider=${provider}

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
