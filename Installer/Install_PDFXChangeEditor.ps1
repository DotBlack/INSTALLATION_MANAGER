# get the current directory
$rootDirectory = $PSScriptRoot

# installfile
$installFile = $rootDirectory + "\PDFXVE9.exe"
Write-Host $installFile
# arguments
$installArguments = "/SILENT /NORESTART"
Write-Host $installArguments

# default install block
Start-Process -FilePath "$installFile" -ArgumentList "$installArguments" -Wait 