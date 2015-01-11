# Dropbox Batch Accounts Creation

This package is meant to create "fake" Dropbox accounts in batch to link them to your account (and gain some storage).

## Setup

Clone the repository on your machine and ensure you have `Vagrant` (>= 1.5) installed.
Add the box : `vagrant box add ubuntu/trusty64`.

Then, `cp config/config.ini.dist config/config.ini` and adapt the values of `config/config.ini` to your needs.

```
[config]
action = "both" # Can be "create", "link" or "both". Will only create the Dropbox account, only link it, or do both.
anonymity = "false" # Uses TOR to have an anonymous IP address
dropboxPartnerLink = "https://db.tt/xxxxxxxx" # The link to the Dropbox account for which you want to increase the available space.
accountIdStart = 1 # The ID of the first account in the loop
accountIdStop = 10 # The ID of the last account in the loop (use the same one as accountIdStart to have no loop)
accountFirstName = "John" # The created account's firstname
accountLastName = "Doe" # The created account's lastname
accountEmail = "myfakedropboxaccount.%s@yopmail.com" # The created account's email. "%s" will be replaced by the account ID from the loop.
accountPassword = "123123" # The created account's password
```

## Run

Simply run `bash run.sh` in your terminal and watch the magic happen (PS: you will be prompted for your sudo password).
