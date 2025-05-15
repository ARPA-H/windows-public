# Remove Trellix from ARPA-H Windows computers
# Gerald Hegele 5/14/25

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
$agentpath = "C:\Program Files\McAfee\Agent\x86"
$folder = "C:\temp\logs"

#check for log folder
if (Test-path -Path $folder) {
Write-Host "Path Exists"
} else {
New-Item -ItemType "directory" -Path "C:\temp"
New-Item -ItemType "directory" -Path "C:\temp\logs"
}
Start-Transcript -Path "C:\temp\logs\RemoveTrellix.log" -Append
$starttime= get-date
Write-host $starttime

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
if (Test-path -Path $agentpath) {
Write-Host "Uninstalling Trellix Agent"
Set-Location -Path $agentpath
.\FrmInst.exe /Silent /FORCEUNINSTALL
Start-Sleep -Seconds 180
} 
else 
{
Write-Host "Trellix Agent not installed"
}

Function FinalcheckforApps {
#Final check for installed apps
$appsstillinstalled = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Trellix*" }
}

FinalcheckforApps

if ($null -eq $appsstillinstalled) {
Write-Host "Trellix Removal Process Complete"
} else 
 {
Write-Host "apps still installed...." $appsstillinstalled.Name
Write-Host "reruning uninstall commands"
RemoveTrellixAgents
Start-Sleep -Seconds 90
FinalcheckforApps
Write-Host "apps still installed...." $appsstillinstalled.Name
}

Stop-Transcript
