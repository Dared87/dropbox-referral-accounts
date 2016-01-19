#!/bin/bash
ACCOUNT_ID=$1
RUN_OPTIONS="--ssl-protocol=any --ignore-ssl-errors=true --web-security=false --cookies-file=/tmp/cookies.txt"

echo "Read configuration file"
source /vagrant/config/config.cfg

# Add Anonymity
if [ "${anonymity}" = true ] ; then
    bash /vagrant/scripts/anonymity.sh
    TOR_INSTALL_STATUS=$?
    RUN_OPTIONS="${RUN_OPTIONS} --proxy=127.0.0.1:9050 --proxy-type=socks5"

    echo "Check what the IP address is through TOR proxy"
    curl -sS --socks5 127.0.0.1:9050 https://api.ipify.org/?format=json
    GET_IP_STATUS=$?

    if [ "${TOR_INSTALL_STATUS}" -gt 0 ] || [ "${GET_IP_STATUS}" -gt 0 ] ; then
        echo "TOR was not installed or configured properly. Aborting."
        exit 1;
    fi
fi

# Add logging flags
if [ "none" != "${logging}" ] ; then
    RUN_OPTIONS="${RUN_OPTIONS} --verbose --log-level=${logging}"
fi

# Fix screenshots path for CasperJS
cd /vagrant

echo "Removing previous runs' screenshots."
rm -f /vagrant/screenshots/*.png

# CasperJS command
echo "Run casperJS with options : ${RUN_OPTIONS}"
RUN="casperjs ${RUN_OPTIONS} /vagrant/scripts/dropbox.js"

# Create the account
if [ "${action}" == "create" ] || [ "${action}" == "both" ] ; then
    echo "Create the referral account #${ACCOUNT_ID} using : ${dropbox_referral_url} !"
    ${RUN} create ${dropbox_referral_url} ${ACCOUNT_ID} ${account_firstname} ${account_lastname} \
        ${account_email} ${account_password} "${timeout}" || true
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
                ${account_email} ${account_password} "${timeout}" || true

            break
        fi

        # Wait before trying again to fetch Dropbox's linking URL from Dropbox daemon's logs, as it may not be there yet
        sleep 5
    done
fi
