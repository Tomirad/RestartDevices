# Requires administrator privileges
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Finding the correct InstanceId (for example: Cisco or Touch-pad)
# Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Cisco*" -or $_.FriendlyName -like "*Touch*" } | Select-Object FriendlyName, InstanceId | Format-List

# Device Identifier Table [Details > Device Instance Path]
$targetInstanceIds = @(
    "ROOT\CISCOUSBCONSOLEWINDOWSDRIVER\0000"
)
$devices = Get-PnpDevice | Where-Object { $targetInstanceIds -contains $_.InstanceId }

if ($null -eq $devices) {
    Write-Host "No devices with the specified InstanceId were found!" -ForegroundColor Red
    Read-Host "ENTER to close the window . . ." Red
    exit
}

Write-Host "Starting the restart procedure for $($devices.Count) devices ..." -ForegroundColor Cyan

# --- FOR 1: DISABLE DEVICES ---
foreach ($dev in $devices) {
    Write-Host "Disabling: $($dev.FriendlyName) . . ." -ForegroundColor Yellow
    pnputil /disable-device "$($dev.InstanceId)" | Out-Null
}

Write-Host "Waiting (approx. 2 seconds) for resources to be released . . ." -ForegroundColor Gray
Start-Sleep -Seconds 2

# --- FOR 2: ENABLE DEVICES ---
foreach ($dev in $devices) {
    Write-Host "Enabling: $($dev.FriendlyName) . . ." -ForegroundColor Green
    pnputil /enable-device "$($dev.InstanceId)" | Out-Null
}

#Read-Host -Prompt "ENTER to close the window . . ."
