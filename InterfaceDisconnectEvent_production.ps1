#Copyright 2022 - Tom van Pelt

try {
    #Get Last Interface Adapter Disconnect Event from last 24 hours
    $lastIfDiscEvent = Get-WinEvent -MaxEvents 1 -FilterHashtable @{
    LogName = "System";
    ID = 27;
    Level = 3; #warning
    StartTime = (Get-Date).AddDays(-1); #last 24 hours
    } -ErrorAction Stop
}
catch [Exception] {
    if ($_.Exception -match "No events were found that match the specified selection criteria") {
        return "No Events Found."; #stop script if no events are found
    }
}

#Get Times:
$lastIfDiscEventTime = ($lastIfDiscEvent).TimeCreated;
$lastIfDiscEventTimePlus = $lastIfDiscEventTime.addMinutes(1); #create 2 minute time window
$lastIfDiscEventTimeMin = $lastIfDiscEventTime.addMinutes(-1);
$lastBootUptime = (Get-CimInstance -ClassName win32_operatingsystem).LastBootUpTime;

#Info Prints:
Write-Host "Last Ethernet Disconnect Event Time: $lastIfDiscEventTime";
Write-Host "Last Boot Uptime: $lastBootUptime";

$isReboot = "True" #0 if a reboot or startup, 1 if not a reboot or startup
if (($lastBootUptime -gt $lastIfDiscEventTimeMin) -and ($lastBootUptime -lt $lastIfDiscEventTimePlus)) {
    Write-Host "Disconnect event was a reboot or Startup.";
}
elseif (($lastIfDiscEventTimePlus.addSeconds(1)) -gt $lastBootUptime) {
    Write-Host "Interface is Disconnected.";
    $isReboot = "False"; #check failed is true
}

Write-Host "`nEvent Message: " -NoNewline;
($lastEthDisconnectEvent).Message;
Write-Host "`nProviderName: " -NoNewline;
($lastEthDisconnectEvent).ProviderName;
