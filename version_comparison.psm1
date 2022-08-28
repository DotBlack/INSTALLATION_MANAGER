# returns true if the if we need to update the software
# @param1 = installpackage - Version
# @param2 = installed - Version
function get_need_to_update_status($version_installpackage, $version_installed)
{
    # compare from the back to the front
    # the front has a higher priority
    # splits versions at each . and creates a list of strings for the version
    $version_installpackage_split = $version_installpackage.Split(".")
    $version_installed_split = $version_installed.Split(".")

    $minSize = 0
    # checks the amount of version-segments and takes the minimumSize
    if($version_installpackage_split.length -lt $version_installed_split.length)
    {
        $minSize = $version_installpackage_split.Length
    }
    else
    {
        $minSize = $version_installed_split.Length
    }

    # from top to bottom   
    for($i = 0; $i -lt $minSize; $i++)
    {
        # check if any version-block is not valid
        if(!($null -eq $version_installpackage_split[$i]) -and !($null -eq $version_installed_split[$i]))
        {
            # converts the version to decimal and compares them
            if([decimal]$version_installpackage_split[$i] -gt [decimal]$version_installed_split[$i])
            {
                # returns true if we need to update
                return $true
            }
        }
    }
    # return default false
    return $false
}
Export-ModuleMember -function get_need_to_update_status