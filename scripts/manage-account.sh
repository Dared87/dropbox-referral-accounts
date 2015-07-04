#!/bin/bash
ACCOUNT_ID=$1
RUN_OPTIONS="--ssl-protocol=any --ignore-ssl-errors=true --web-security=false"

echo "Read configuration file"
source /vagrant/config/config.cfg

# Add Anonymity
if [ "${anonymity}" = true ] ; then
    bash /vagrant/scripts/anonymity.sh
    RUN_OPTIONS="${RUN_OPTIONS} --proxy=127.0.0.1:9050 --proxy-type=socks5"
fi

# Add logging flags
if [ "none" != "${logging}" ] ; then
    RUN_OPTIONS="${RUN_OPTIONS} --verbose --log-level=${logging}"
fi

# Fix screenshots path for CasperJS
cd /vagrant

# CasperJS command
echo "Run casperJS with options : ${RUN_OPTIONS}"
RUN="casperjs ${RUN_OPTIONS} /vagrant/scripts/dropbox.js"

if [ "${anonymity}" = true ] ; then
    curl -sS --socks5 127.0.0.1:9050 https://api.ipify.org?format=json
fi

# Create the account
if [ "${action}" == "create" ] || [ "${action}" == "both" ] ; then
    echo "Create the referral account #${ACCOUNT_ID} using : ${dropbox_referral_url} !"
    ${RUN} create ${dropbox_referral_url} ${ACCOUNT_ID} ${account_firstname} ${account_lastname} \
        ${account_email} ${account_password} || true
fi

# Link the account
if [ "${action}" == "link" ] || [ "${action}" == "both" ] ; then

    # Start a new Dropbox daemon
    ${HOME}/.dropbox-dist/dropboxd > ${HOME}/dropbox.log 2>&1 &

    while [ 1 ]
    do
        DROPBOX_LINK_URL=$(grep -Paos '(?<=Please visit ).*(?= to link this device.)' ${HOME}/dropbox.log)
        RESULT=$?

        if [ ${RESULT} -eq 0 ] ; then

            # Get only the last line
            DROPBOX_LINK_URL=$(echo "${DROPBOX_LINK_URL}" | tail -n1)

            echo "Link the referral account #${ACCOUNT_ID} using : ${DROPBOX_LINK_URL} !"
            ${RUN} link ${DROPBOX_LINK_URL} ${ACCOUNT_ID} ${account_firstname} ${account_lastname} \
                ${account_email} ${account_password} || true

            break
        fi

        # Wait before trying again to fetch Dropbox's linking URL from Dropbox daemon's logs, as it may not be there yet
        sleep 5
    done
fi
