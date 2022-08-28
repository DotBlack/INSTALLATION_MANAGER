# get the current directory
$rootDirectory = $PSScriptRoot

# installfile
$installFile = $rootDirectory + "\AcroRdrDC2200220191_de_DE.exe"
Write-Host $installFile
# arguments
$installArguments = "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES"
Write-Host $installArguments

# default install block
Start-Process -FilePath "$installFile" -ArgumentList "$installArguments" -Wait 