#!/bin/bash
ACCOUNT_ID=$1

echo "Account ID is ${ACCOUNT_ID} !"

echo "Read configuration file"
source /vagrant/libs/ini-parser.sh
read_ini "/vagrant/config/config.ini" "config"
EMAIL_FORMAT=${INI__config__emailFormat}
DROPBOX_PARTNER_LINK=${INI__config__dropboxPartnerLink}

RUN="casperjs --ssl-protocol=any --ignore-ssl-errors=true /vagrant/scripts/manage-account.js"

# Fix screenshots path for CasperJS
cd /vagrant

# Create the account
echo "Create the Dropbox account ${ACCOUNT_ID} via URL : ${DROPBOX_PARTNER_LINK} !"
${RUN} create ${ACCOUNT_ID} ${EMAIL_FORMAT} ${DROPBOX_PARTNER_LINK} || true

# Link the account
echo "Start a new Dropbox daemon"
${HOME}/.dropbox-dist/dropboxd > ${HOME}/dropbox.log 2>&1 &

WAIT=5
while [ 1 ]
do
    OUTPUT=$(grep -Pos '(?<=Please visit ).*(?= to link this device.)' ${HOME}/dropbox.log)
    RESULT=$?

    if [ ${RESULT} -eq 0 ] ; then

        # Get only the last line
        DROPBOX_ACTIVATION_LINK=$(echo "${OUTPUT}" | tail -n1)
        echo "Account ${ACCOUNT_ID} : ${DROPBOX_ACTIVATION_LINK}" | sudo tee -a /vagrant/output.log

        echo "Activate the Dropbox account ${ACCOUNT_ID} via URL : ${DROPBOX_ACTIVATION_LINK} !"
        ${RUN} link ${ACCOUNT_ID} ${EMAIL_FORMAT} ${DROPBOX_ACTIVATION_LINK} || true

        break
    fi

    echo "Wait ${WAIT} seconds before trying to fetch Dropbox activation URL from the daemon's logs..."
    sleep ${WAIT}
done
