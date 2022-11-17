#Copyright 2022 - Tom van Pelt

#Get Last Interface Adapter Disconnect Event from last 24 hours
try {
    $lastIfDiscEvent = Get-WinEvent -MaxEvents 1 -FilterHashtable @{
    LogName = "System";
    ID = 27;
    Level = 3;
    #StartTime = (Get-Date).AddDays(-1);
    StartTime = (Get-Date).AddHours(-3);
    } -ErrorAction Stop
}
catch [Exception] {
    if ($_.Exception -match "No events were found that match the specified selection criteria") {
        #Write-Host "No events found";
        return "No Events Found.";
    }
}

#Get Times:
$lastIfDiscEventTime = ($lastIfDiscEvent).TimeCreated;
$lastIfDiscEventTimePlus = $lastIfDiscEventTime.addMinutes(1);
$lastIfDiscEventTimeMin = $lastIfDiscEventTime.addMinutes(-1);
$lastBootUptime = (Get-CimInstance -ClassName win32_operatingsystem).LastBootUpTime;

#Info Prints:
Write-Host "Last Ethernet Disconnect Event Time: $lastIfDiscEventTime";
Write-Host "Last Boot Uptime: $lastBootUptime";

#Test Prints:
#Write-Host "Last Ethernet Disconnect Event Time Plus 1 Minute: $lastEthDisconnectEventPlus"
#Write-Host "Last Ethernet Disconnect Event Time Min 1 Minute: $lastEthDisconnectEventMin"
$isReboot = "True" #0 if a reboot or startup, 1 if not a reboot or startup
if (($lastBootUptime -gt $lastIfDiscEventTimeMin) -and ($lastBootUptime -lt $lastIfDiscEventTimePlus)) {
    #last ethernet disconnect event was a reboot (or startup)
    Write-Host "Reboot or Startup.";
}
elseif (($lastIfDiscEventTimePlus.addSeconds(1)) -gt $lastBootUptime) {
    #failed
    Write-Host "Not a Reboot.";
    Write-Host "`nEvent Message: " -NoNewline;
    ($lastEthDisconnectEvent).Message;
    Write-Host "`nProviderName: " -NoNewline;
    ($lastEthDisconnectEvent).ProviderName;
    $isReboot = "False"; #check failed is true
}
