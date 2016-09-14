

# List of email Providers for email generation
$EMAIL_PROVIDERS = @("aol.com", "att.net", "comcast.net", "facebook.com", "gmail.com", "gmx.com", "googlemail.com", "google.com", "hotmail.com", "hotmail.co.uk", "mac.com", "me.com", "mail.com", "msn.com", "live.com", "sbcglobal.net", "verizon.net", "yahoo.com", "yahoo.co.uk", "gmx.de", "hotmail.de", "live.de", "online.de", "t-online.de", "web.de", "yahoo.de")

#
# Generate a MAC Address that can be used by VirtualBox.
# See https://www.virtualbox.org/ticket/10778 for more information.
#
Function generate_mac_address_for_virtualbox {
	[CmdletBinding()]
	Param(
		[Parameter()]
		[string] $Separator = "-"
	)

	[string]::join($Separator, @(
		# "Locally administered address"
		# any of x2, x6, xa, xe
		"02",
		("{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255)),
		("{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255)),
		("{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255)),
		("{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255)),
		("{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255))
	))
}


Function create_box {
	[CmdletBinding()]
	Param(
		[Parameter()]
		[string] $acc
	)
	
	$ACCOUNT_ID = $acc
	$MAC_ADDRESS = generate_mac_address_for_virtualbox("")
	
	$conf = get_config('config\config.cfg')
	
    $RESP = Invoke-RestMethod -Uri "http://api.randomuser.me/?inc=email,name&nat=$($CONF.location)&noinfo" | select -ExpandProperty results
    $EMAIL_STRIPPED = $RESP.email.Split('@')[0]
    $RANDOM_NUMBER = Get-Random -Minimum 1 -Maximum 99
    $RANDOM_PROVIDER = $EMAIL_PROVIDERS | Get-Random
    $EMAIL_NEW = "$($EMAIL_STRIPPED)$($RANDOM_NUMBER)@$($RANDOM_PROVIDER)"
	
    Write-Host "Create a temporary Vagrant box #$($ACCOUNT_ID) with the MAC address $($MAC_ADDRESS)..."

    [Environment]::SetEnvironmentVariable("ACCOUNT_ID", $ACCOUNT_ID, "Process")
    [Environment]::SetEnvironmentVariable("EMAIL", $EMAIL_NEW, "Process")
    [Environment]::SetEnvironmentVariable("FIRST", $RESP.name.first, "Process")
    [Environment]::SetEnvironmentVariable("LAST", $RESP.name.last, "Process")
    [Environment]::SetEnvironmentVariable("MAC_ADDRESS", $MAC_ADDRESS, "Process")

    vagrant up --provision --provider=$($conf.provider)
}

Function get_config {
	[CmdletBinding()]
	Param(
		[Parameter()]
		[string] $file = ""
	)
	
	Get-Content $file | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("#") -ne $True)) { $h.Add($k[0], ($k[1] -replace '"', '')) } }
	 
	return $h
}

create_box(1)
