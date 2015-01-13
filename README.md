# Dropbox Batch Referral Accounts

This package is meant to create referral Dropbox accounts to link them to your own account (to gain some storage).

## Setup

Clone the repository `git clone git@bitbucket.org:gnutix/dropbox-batch-accounts.git && cd dropbox-batch-accounts`.
[Install vagrant](https://www.vagrantup.com/downloads.html) and add the box : `vagrant box add ubuntu/trusty64`.

Then, copy the default configuration file `cp config/config.ini.dist config/config.ini` and adapt the following values
of `config/config.ini` to your needs :

```
# The referral link of the Dropbox account you want to increase the storage of.
dropboxReferralLink = "https://db.tt/xxxxxxxx"
 
# The referral account's email. "%d" will be replaced by the account ID from the loop.
accountEmail = "change_me_for_something_unique.%d@yopmail.com" 
```

## Run

Execute `bash run.sh <OPTIONS>` in your terminal and watch the magic happen (PS: you will be prompted for your sudo password).
`<OPTIONS>` can be a single integer (`1`) or two integers (`1 32`) for managing multiple accounts (1, 2, 3,..., 31, 32).
