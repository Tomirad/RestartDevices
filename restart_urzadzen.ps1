# Kodowanie PL: Windows-1250

# Wymaga uprawnień administratora
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Wyszukiwanie poprawnego InstanceId
# Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Cisco*" -or $_.FriendlyName -like "*Touch*" } | Select-Object FriendlyName, InstanceId | Format-List

# Tablica Identyfikatorów Urządzeń [Szczegóły > Ścieżka wystąpienia urządzenia]
$targetInstanceIds = @(
    "ROOT\CISCOUSBCONSOLEWINDOWSDRIVER\0000"
)
$devices = Get-PnpDevice | Where-Object { $targetInstanceIds -contains $_.InstanceId }

if ($null -eq $devices) {
    Write-Host "Nie znaleziono urządzeń o podanych InstanceId!" -ForegroundColor Red
    Read-Host "ENTER, aby zamknąć okno . . ." Red
    exit
}

Write-Host "Rozpoczynam procedurę restartu dla $($devices.Count) urządzeń . . ." -ForegroundColor Cyan

# --- FOR 1: DISABLE DEVICES ---
foreach ($dev in $devices) {
    Write-Host "Wyłączanie: $($dev.FriendlyName) . . ." -ForegroundColor Yellow
    pnputil /disable-device "$($dev.InstanceId)" | Out-Null
}

Write-Host "Oczekiwanie (ok. 2 sekund) na zwolnienie zasobów . . ." -ForegroundColor Gray
Start-Sleep -Seconds 2

# --- FOR 2: ENABLE DEVICES ---
foreach ($dev in $devices) {
    Write-Host "Włączanie: $($dev.FriendlyName) . . ." -ForegroundColor Green
    pnputil /enable-device "$($dev.InstanceId)" | Out-Null
}

#Read-Host -Prompt "ENTER, aby zamknąć okno . . ."
