# Dropbox Referral Accounts

I believe it should be easy to use Dropbox. Having enough space makes it easier to use Dropbox without hassle.

In order to do that, I created this package, which role is to increase your Dropbox account space, without requiring
any effort.

But how, you may ask ? Simply by creating random "referral accounts" and linking them to your own.

## Prerequisites

Install up-to-date versions of [Vagrant](https://www.vagrantup.com/downloads.html) and
[VirtualBox](https://www.virtualbox.org/wiki/Downloads).

## Setup

1. Clone this repository : `git clone git@bitbucket.org:gnutix/dropbox-referral-accounts.git && cd dropbox-referral-accounts`
2. Copy the example configuration file : `cp config/config.ini.dist config/config.ini`
3. Adapt the following values of `config/config.ini` to your needs :

```
# The referral link of the Dropbox account for which you want to increase the storage.
dropboxReferralLink = "https://db.tt/xxxxxxxx"
 
# The referral accounts' email. "%d" will be replaced by the account ID from the loop.
accountEmail = "change_me_for_something_unique.%d@yopmail.com" 
```

## Run the script

Execute `bash run.sh <ACCOUNT_ID>` in your terminal and watch the magic happen (PS: you will be prompted for your sudo password).
`<ACCOUNT_ID>` can be either :

* empty/not provided (default value of `1` is used), which results in one account being handled
* a single integer (`23`), which results in one account being handled
* two integers separated by a space (`23 42`), which results in multiple accounts being handled, looping between
  23 and 42 (example: 23, 24, 25, ... , 40, 41, 42).

## Tips

If you have no referral accounts linked to your account yet, you can use `bash run.sh 1 32` to get the maximum space
possible at once.
