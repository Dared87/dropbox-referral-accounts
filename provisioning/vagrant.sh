#!/bin/bash
ACCOUNT_ID=$1
RUN_OPTIONS="--ssl-protocol=any --ignore-ssl-errors=true --web-security=false"

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

if [ "none" != "${RUN_LOGGING}" ] ; then
    RUN_OPTIONS="${RUN_OPTIONS} --verbose --log-level=${RUN_LOGGING}"
fi

echo "Setup Vagrant box for account ${ACCOUNT_ID} !"

# Fix screenshots path for CasperJS
cd /vagrant
RUN="casperjs ${RUN_OPTIONS} /vagrant/scripts"

# Create the account
if [ "${ACTION}" == "create" ] || [ "${ACTION}" == "both" ] ; then
    echo "Create the Dropbox account ${ACCOUNT_ID} via URL : ${DROPBOX_REFERRAL_URL} !"
    ${RUN}/manage-account.js create ${DROPBOX_REFERRAL_URL} ${ACCOUNT_ID} ${ACCOUNT_FIRSTNAME} ${ACCOUNT_LASTNAME} \
        ${ACCOUNT_EMAIL} ${ACCOUNT_PASSWORD} || true
fi

# Link the account
if [ "${ACTION}" == "link" ] || [ "${ACTION}" == "both" ] ; then
    echo "Start a new Dropbox daemon"
    ${HOME}/.dropbox-dist/dropboxd > ${HOME}/dropbox.log 2>&1 &

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
