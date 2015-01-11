#!/bin/bash
ACCOUNT_ID=$1
RUN_OPTIONS="--ssl-protocol=tlsv1 --ignore-ssl-errors=true --web-security=no"

echo "Read configuration file"
source /vagrant/libs/ini-parser.sh
read_ini "/vagrant/config/config.ini" "config"
RUN_LOGGING=${INI__config__logging}
ACTION=${INI__config__action}
ACCOUNT_FIRSTNAME=${INI__config__accountFirstName}
ACCOUNT_LASTNAME=${INI__config__accountLastName}
ACCOUNT_EMAIL=${INI__config__accountEmail}
ACCOUNT_PASSWORD=${INI__config__accountPassword}
DROPBOX_REFERRAL_URL=${INI__config__dropboxReferralURL}
ANONYMITY=${INI__config__anonymity}

if [ "none" != "${RUN_LOGGING}" ] ; then
    RUN_OPTIONS="${RUN_OPTIONS} --verbose --log-level=${RUN_LOGGING}"
fi

echo "Setup Vagrant box for account ${ACCOUNT_ID} (using anonymity: ${ANONYMITY}) !"

if [ "${ANONYMITY}" = true ] ; then
    bash /vagrant/provisioning/anonymity.sh
    RUN_OPTIONS="${RUN_OPTIONS} --proxy=127.0.0.1:9050 --proxy-type=socks5"
fi

bash /vagrant/provisioning/browser-manipulation.sh

# Fix screenshots path for CasperJS
cd /vagrant
RUN="casperjs ${RUN_OPTIONS} /vagrant/scripts"

if [ "${ANONYMITY}" = true ] ; then
    echo "Get my IP address"
    ${RUN}/what-is-my-ip.js
fi

# Create the account
if [ "${ACTION}" == "create" ] || [ "${ACTION}" == "both" ] ; then
    echo "Create the Dropbox account ${ACCOUNT_ID} via URL : ${DROPBOX_REFERRAL_URL} !"
    ${RUN}/manage-account.js create ${DROPBOX_REFERRAL_URL} ${ACCOUNT_ID} ${ACCOUNT_FIRSTNAME} ${ACCOUNT_LASTNAME} \
        ${ACCOUNT_EMAIL} ${ACCOUNT_PASSWORD} || true
fi

# Link the account
if [ "${ACTION}" == "link" ] || [ "${ACTION}" == "both" ] ; then
    bash /vagrant/provisioning/dropbox.sh

    WAIT=5
    while [ 1 ]
    do
        DROPBOX_LINK_URL=$(grep -Paos '(?<=Please visit ).*(?= to link this device.)' ${HOME}/dropbox.log)
        RESULT=$?

        if [ ${RESULT} -eq 0 ] ; then

            # Get only the last line
            DROPBOX_LINK_URL=$(echo "${DROPBOX_LINK_URL}" | tail -n1)

            echo "Link the Dropbox account ${ACCOUNT_ID} via URL : ${DROPBOX_LINK_URL} !"
            ${RUN}/manage-account.js link ${DROPBOX_LINK_URL} ${ACCOUNT_ID} ${ACCOUNT_FIRSTNAME} ${ACCOUNT_LASTNAME} \
                ${ACCOUNT_EMAIL} ${ACCOUNT_PASSWORD} || true

            break
        fi

        echo "Wait ${WAIT} seconds before trying to fetch Dropbox activation URL from the daemon's logs..."
        sleep ${WAIT}
    done
fi
