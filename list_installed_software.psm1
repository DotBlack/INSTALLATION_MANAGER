# returns the index of the given software
function getInstalledSoftwareIndex($software_display_name) {
    # remove false positives
    if($software_display_name -eq "") {
        return $false
     }
     # list all installed software-modules
     $InstalledSoftware = Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
     # extra counter to skip if DisplayName is NULL
     $count = 0
     # loop over all installed software-modules
     for($i = 0; $i -le $InstalledSoftware.length; $i++) {
         # get the DisplayName of the current-software-module
         $current_software_display_name = $InstalledSoftware[$i].GetValue('DisplayName');
         # skip null-valued strings
         if($current_software_display_name.Length -gt 0 -and $null -ne $current_software_display_name) {
            # compare the current-software-module-name against the given software_display_name
            if($current_software_display_name.Contains($software_display_name)) {
                # return true for if the display-name was found
                return $count
            }
            #increase counter beacuse it's a valueable and listed software
            $count++
         }
     }
     # default return false
     return -1
}
Export-ModuleMember -function getInstalledSoftwareIndex

# returns a list of uninstallers for the installed softwares
function getInstalledSoftwareUninstallPaths() {
    # list all installed software-modules
    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    # array for the return information
    $Info = @()
    # loop over all installed software-modules
    foreach($obj in $InstalledSoftware){
        # get the UninstallPath
        $UninstallPath = $obj.GetValue('UninstallString')
        # get the DisplayName
        $DisplayName = $obj.GetValue('DisplayName')
        # skip if DisplayName is NULL
        if($null -ne $DisplayName) {
            # add it to the array
            $Info += $UninstallPath + "`n"
        }
    }
    # return the array
    return $Info
}
Export-ModuleMember -function getInstalledSoftwareUninstallPaths

# returns a list of registry-names for all installed softwares 
function getInstalledSoftwareListDisplayNames() {
    # list all installed software-modules
    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    # array for the return information
    $Info = @()
    # loop over all installed software-modules
    foreach($obj in $InstalledSoftware){
        # get the DisplayName
        $DisplayName = $obj.GetValue('DisplayName')
        # skip if DisplayName is NULL
        if($null -ne $DisplayName) {
            # add it to the array
            $Info += $DisplayName + "`n"
        }
    }
    # return the array
    return $Info
}
Export-ModuleMember -function getInstalledSoftwareListDisplayNames

# returns a list of registry-versions for all installed softwares 
function getInstalledSoftwareListDisplayVersions() {
    # list all installed software-modules
    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    # array for the return information
    $Info = @()
    # loop over all installed software-modules
    foreach($obj in $InstalledSoftware){
        # get the DisplayVersion
        $DisplayVersion = $obj.GetValue('DisplayVersion')
        # get the DisplayName
        $DisplayName = $obj.GetValue('DisplayName')
        # skip if DisplayName is NULL
        if($null -ne $DisplayName) {
            # add it to the array
            $Info += $DisplayVersion + "`n"
        }
    }
    # return the array
    return $Info
}
Export-ModuleMember -function getInstalledSoftwareListDisplayVersions

# returns true if the given software is installed
function hasSoftwareInstalled($software_display_name) {
    # remove false positives
    if($software_display_name -eq "") {
       return $false
    }
    # list all installed software-modules
    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    # loop over all installed software-modules
    foreach($obj in $InstalledSoftware) {
        # get the DisplayName of the current-software-module
        $current_software_display_name = $obj.GetValue('DisplayName');
        # skip null-valued strings
        if($current_software_display_name.Length -gt 0) {
            # compare the current-software-module-name against the given software_display_name
            if($current_software_display_name.Contains($software_display_name)) {
                # return true for if the display-name was found
                return $true
            }
        }
    }
    # default return false
    return $false
}
Export-ModuleMember -function hasSoftwareInstalled -Variable software_display_name

# returns the registry-version of the given softwares name
function getSoftwareInstalledVersion($software_display_name) {
    # remove false positives
    if($software_display_name -eq "") {
        return $false
    }
    # list all installed software-modules
    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    # loop over all installed software-modules
    foreach($obj in $InstalledSoftware) {
        # get the DisplayName of the current-software-module
        $current_software_display_name = $obj.GetValue('DisplayName');
        # skip null-valued strings
        if($current_software_display_name.Length -gt 0) {
            # compare the current-software-module-name against the given software_display_name
            if($current_software_display_name.Contains($software_display_name)) {
                # return true for if the display-name was found
                return $obj.GetValue('DisplayVersion')
            }
        }
    }
    # default return -1 ... should never be possible to reach here!
    return -1
}
Export-ModuleMember -function getSoftwareInstalledVersion

# returns the registry-name of the given softwares name
function getSoftwareInstalledDisplayName($software_display_name) {
    # remove false positives
    if($software_display_name -eq "") {
        return $false
    }
    # list all installed software-modules
    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    # loop over all installed software-modules
    foreach($obj in $InstalledSoftware) {
        # get the DisplayName of the current-software-module
        $current_software_display_name = $obj.GetValue('DisplayName');
        # skip null-valued strings
        if($current_software_display_name.Length -gt 0) {
            # compare the current-software-module-name against the given software_display_name
            if($current_software_display_name.Contains($software_display_name)) {
                # return true for if the display-name was found
                return $obj.GetValue('DisplayName')
            }
        }
    }
    # default return -1 ... should never be possible to reach here!
    return ""
}
Export-ModuleMember -function getSoftwareInstalledDisplayName