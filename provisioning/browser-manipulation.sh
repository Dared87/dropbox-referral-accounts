#!/bin/bash
function install() {
    local RESOURCES=/vagrant/provisioning/resources
    local INSTALL=/usr/local/share

    PACKAGE=$1
    ARCHIVE=$2
    TAR_OPTIONS=$3

    echo "Install ${PACKAGE}"
    sudo mkdir -p ${INSTALL}/${PACKAGE}
    sudo tar ${TAR_OPTIONS} ${RESOURCES}/${ARCHIVE} -C ${INSTALL}/${PACKAGE} --strip 1
    sudo ln -sf ${INSTALL}/${PACKAGE}/bin/${PACKAGE} /usr/local/bin/${PACKAGE}
}

if [ -z "$(which phantomjs)" ] ; then
    echo "Install PhantomJS dependencies"
    sudo apt-get update
    sudo apt-get install -y build-essential chrpath libssl-dev libxft-dev
    sudo apt-get install -y libfreetype6 libfreetype6-dev
    sudo apt-get install -y libfontconfig1 libfontconfig1-dev

    install "phantomjs" "phantomjs-1.9.8-linux-x86_64.tar.bz2" "xjf"
fi

if [ -z "$(which casperjs)" ] ; then
    install "casperjs" "n1k0-casperjs-1.1-beta3-0-g4f105a9.tar.gz" "xzf"
fi
