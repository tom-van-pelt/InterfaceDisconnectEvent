#Copyright 2022 - Tom van Pelt

$timeFrame = $inputHours 

#Get Last Interface Adapter Disconnect Event from last x hours
try {
    $lastIfDiscEvent = Get-WinEvent -MaxEvents 1 -FilterHashtable @{ #get 1 disconnect event
    LogName = "System";
    ID = 27;
    Level = 3; #warning
    StartTime = (Get-Date).AddHours(-$timeFrame); #last x hours
    } -ErrorAction Stop
}
catch [Exception] {
    if ($_.Exception -match "No events were found that match the specified selection criteria") {
        return "No Events Found."; #stop script if no events are found
    }
    return;
}

#Get Times:
$lastIfDiscEventTime = ($lastIfDiscEvent).TimeCreated;
$lastIfDiscEventTimePlus = $lastIfDiscEventTime.addMinutes(1); #create 2 minute time window
$lastIfDiscEventTimeMin = $lastIfDiscEventTime.addMinutes(-1);
$lastBootUptime = (Get-CimInstance -ClassName win32_operatingsystem).LastBootUpTime;

#Info Prints:
Write-Host "Last Ethernet Disconnect Event Time: $lastIfDiscEventTime";
Write-Host "Last Boot Uptime: $lastBootUptime";

$isReboot = "True" #True if a reboot or startup, False if not a reboot or startup
if (($lastBootUptime -gt $lastIfDiscEventTimeMin) -and ($lastBootUptime -lt $lastIfDiscEventTimePlus)) {
    Write-Host "Disconnect event was a reboot or Startup.";
}
elseif (($lastIfDiscEventTimePlus.addSeconds(1)) -gt $lastBootUptime -or (($lastIfDiscEventTimeMin.addSeconds(-1)) -lt $lastBootUptime)) {
    Write-Host "Interface is Disconnected.";
    $isReboot = "False";
}

Write-Host "`nEvent Message: " -NoNewline;
($lastIfDiscEvent).Message;
Write-Host "`nProviderName: " -NoNewline;
($lastIfDiscEvent).ProviderName;
