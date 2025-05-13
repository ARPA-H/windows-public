# Remove Trellix from ARPA-H Windows computers
# Gerald Hegele 5/13/25

# Define the list of Trellix applications to uninstall
$appsToRemove = @(
    "Trellix Endpoint Security Adaptive Threat Protection",
    "Trellix Endpoint Security Threat Prevention",
    "Trellix Endpoint Security Firewall",
    "Trellix Endpoint Security Web Control",
    "Trellix Endpoint Security Platform",
    "Trellix Endpoint Security (HX) Agent",
    "FireEye Endpoint Agent"
)

$Agentremoval = "C:\Program Files\McAfee\Agent\x86\FrmInst.exe"

$folder = "C:\temp\logs"
if (Test-path -Path $folder) {
"Path Exists"
} else {
New-Item -ItemType "directory" -Path "C:\temp"
New-Item -ItemType "directory" -Path "C:\temp\logs"
}

Start-Transcript -Path "C:\temp\logs\RemoveTrellix.log" -Append


function RemoveTrellixAgents {

    foreach ($app in $appsToRemove) {
        $uninstallString = (Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%$app%'").Uninstall()
    
        if ($uninstallString) {
            Write-Host "Uninstalling $app..."
            Invoke-Expression $uninstallString
        } else {
            Write-Host "$app not found."
        }
    }
}

RemoveTrellixAgents

# Manual removal of the "Trellix Agent" via EXE as the WMI removal attempt fails
Write-Host "Uninstalling Trellix Agent"
Set-Location -Path "C:\Program Files\McAfee\Agent\x86"
.\FrmInst.exe /Silent /FORCEUNINSTALL

Start-Sleep -Seconds 180

#Final check for installed apps
$appsremoved = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Trellix*" }
Write-Host "final check $appsremoved"

if ($appsremoved -eq $null) {
Write-Host "Uninstallation process complete."
} else {
RemoveTrellixAgents
Write-Host "Uninstallation process failed."
}
