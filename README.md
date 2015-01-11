# Dropbox Batch Referral Accounts

This package is meant to create referral Dropbox accounts in batch to link them to your own account (to gain some storage).

## Setup

Clone the repository `git clone git@bitbucket.org:gnutix/dropbox-batch-accounts.git && cd dropbox-batch-accounts`.
[Install vagrant](https://www.vagrantup.com/downloads.html) and add the box : `vagrant box add ubuntu/trusty64`.

Then, copy the default configuration file `cp config/config.ini.dist config/config.ini` and adapt the values of `config/config.ini` to your needs.

```
[config]
action = "both" # Can be "create", "link" or "both". Will create the referral Dropbox account, link it (link the account with the Dropbox installation), or do both.
anonymity = "false" # Uses TOR to ensure usage of dynamic, variable (and therefore anonymous) IP addresses
dropboxPartnerLink = "https://db.tt/xxxxxxxx" # The referral link to the Dropbox account for which you want to increase the storage.
accountIdStart = 1 # The ID of the first referral account in the loop
accountIdStop = 10 # The ID of the last referral account in the loop (use the same one as accountIdStart to have no loop)
accountFirstName = "John" # The referral account's firstname
accountLastName = "Doe" # The referral account's lastname
accountEmail = "myfakedropboxaccount.%s@yopmail.com" # The referral account's email. "%s" will be replaced by the account ID from the loop.
accountPassword = "123123" # The referral account's password
```

## Run

Simply run `bash run.sh` in your terminal and watch the magic happen (PS: you will be prompted for your sudo password).
