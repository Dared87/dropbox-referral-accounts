# Dropbox Referral Accounts

I believe it should be easy and painless to use Dropbox. I believe not having enough available space is a pain.

I created this package to relieve us from this pain, by adding up to 16 Gb more on our Dropbox account, without
requiring any effort or manual intervention.

How ? By automating the creation and linking of random "referral accounts" to a Dropbox account of our choice.

**In details:** the scripts create Vagrant boxes with varying MAC addresses, install Dropbox's software on the box ;
then crawl Dropbox's website using CasperJS/PhantomJS : first to create a random referral account via a configured
referral link, secondly to link the referral account with the software installation.

Tada ! Your space has increased of 500 Mb. Do it 32 times, and you're up to 16 Gb (the maximum allowed by Dropbox).

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

Execute `bash run.sh <ACCOUNT_ID>` in your terminal and watch the magic happen (PS: you will be prompted for your sudo
password).
`<ACCOUNT_ID>` can be either :

* empty/not provided (default value of `1` is used), which results in one account being handled
* a single integer (`23`), which results in one account being handled
* two integers separated by a space (`23 42`), which results in multiple accounts being handled, looping between
  23 and 42 (example: 23, 24, 25, ... , 40, 41, 42).

## Notes

* If you have no referral accounts linked to your account yet, you can use `bash run.sh 1 32` to get the maximum space
possible (16 Gb) at once.
* Running the script the first time may take a while, as it has to download a Vagrant box of ~500 Mb.
