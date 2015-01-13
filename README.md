# Dropbox Batch Referral Accounts

This package is meant to create referral Dropbox accounts to link them to your own account (to gain some storage).

## Prerequisites

Install the latest versions of [Vagrant](https://www.vagrantup.com/downloads.html) and
[VirtualBox](https://www.virtualbox.org/wiki/Downloads).

## Setup

1. Clone the repository : `git clone git@bitbucket.org:gnutix/dropbox-batch-accounts.git && cd dropbox-batch-accounts`
2. Copy the configuration sample file : `cp config/config.ini.dist config/config.ini`
3. Adapt the following values of `config/config.ini` to your needs :

```
# The referral link of the Dropbox account you want to increase the storage of.
dropboxReferralLink = "https://db.tt/xxxxxxxx"
 
# The referral account's email. "%d" will be replaced by the account ID from the loop.
accountEmail = "change_me_for_something_unique.%d@yopmail.com" 
```

## Run

Execute `bash run.sh <OPTIONS>` in your terminal and watch the magic happen (PS: you will be prompted for your sudo password).
`<OPTIONS>` can be either :

* empty/not provided (default value of `1` is used)
* a single integer (`23`)
* two integers separated by a space (`23 42`), which results in a loop between 23 and 42 (23, 24, 25,... 40, 41, 42).

## Tips

If you have no referral accounts linked to your account yet, you can use `bash run.sh 1 32` to get the maximum space
possible at once.
