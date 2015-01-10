# Dropbox Batch Accounts Creation

This package is meant to create "fake" Dropbox accounts in batch to link them to your account (and gain some storage).

## Setup

Clone the repository on your machine and ensure you have `Vagrant` (>= 1.5) installed.
Then, `cp config/config.ini.dist config/config.ini` and adapt the values of `config/config.ini` to your needs.

Add the box : `vagrant box add ubuntu/trusty64`.

## Run

Simply run `bash run.sh` in your terminal and watch the magic happen (PS: you will be prompted for your sudo password).
