#!/bin/bash
ACCOUNT_ID=$1
RUN_TIMEOUT=20000
RUN_OPTIONS="--ssl-protocol=tlsv1 --ignore-ssl-errors=true"

echo "Read configuration file"
source /vagrant/libs/ini-parser.sh
read_ini "/vagrant/config/config.ini" "config"
ACTION=${INI__config__action}
ACCOUNT_FIRSTNAME=${INI__config__accountFirstName}
ACCOUNT_LASTNAME=${INI__config__accountLastName}
ACCOUNT_EMAIL=${INI__config__accountEmail}
ACCOUNT_PASSWORD=${INI__config__accountPassword}
DROPBOX_PARTNER_LINK=${INI__config__dropboxPartnerLink}
ANONYMITY=${INI__config__anonymity}

echo "Setup Vagrant box for account ${ACCOUNT_ID} (using anonymity: ${ANONYMITY}) !"

if [ "${ANONYMITY}" = true ] ; then
    bash /vagrant/provisioning/anonymity.sh
    RUN_TIMEOUT=120000
    RUN_OPTIONS="${RUN_OPTIONS} --proxy=127.0.0.1:9050 --proxy-type=socks5"
fi

bash /vagrant/provisioning/browser-manipulation.sh
bash /vagrant/provisioning/dropbox.sh

# Fix screenshots path for CasperJS
cd /vagrant
RUN="casperjs ${RUN_OPTIONS} /vagrant/scripts"

if [ "${ANONYMITY}" = true ] ; then
    echo "Get my IP address"
    ${RUN}/what-is-my-ip.js --timeout=${RUN_TIMEOUT}
fi

# Create the account
if [ "${ACTION}" == "create" ] || [ "${ACTION}" == "both" ] ; then
    echo "Create the Dropbox account ${ACCOUNT_ID} via URL : ${DROPBOX_PARTNER_LINK} !"
    ${RUN}/manage-account.js create ${DROPBOX_PARTNER_LINK} ${ACCOUNT_ID} ${ACCOUNT_FIRSTNAME} ${ACCOUNT_LASTNAME} \
        ${ACCOUNT_EMAIL} ${ACCOUNT_PASSWORD} --timeout=${RUN_TIMEOUT} || true
fi

# Link the account
if [ "${ACTION}" == "link" ] || [ "${ACTION}" == "both" ] ; then
    echo "Start a new Dropbox daemon"
    ${HOME}/.dropbox-dist/dropboxd > ${HOME}/dropbox.log 2>&1 &

    WAIT=5
    while [ 1 ]
    do
        OUTPUT=$(grep -Paos '(?<=Please visit ).*(?= to link this device.)' ${HOME}/dropbox.log)
        RESULT=$?

        if [ ${RESULT} -eq 0 ] ; then

            # Get only the last line
            DROPBOX_ACTIVATION_LINK=$(echo "${OUTPUT}" | tail -n1)

            echo "Activate the Dropbox account ${ACCOUNT_ID} via URL : ${DROPBOX_ACTIVATION_LINK} !"
            ${RUN}/manage-account.js link ${DROPBOX_ACTIVATION_LINK} ${ACCOUNT_ID} ${ACCOUNT_FIRSTNAME} ${ACCOUNT_LASTNAME} \
                ${ACCOUNT_EMAIL} ${ACCOUNT_PASSWORD} --timeout=${RUN_TIMEOUT} || true

            break
        fi

        echo "Wait ${WAIT} seconds before trying to fetch Dropbox activation URL from the daemon's logs..."
        sleep ${WAIT}
    done
fi
