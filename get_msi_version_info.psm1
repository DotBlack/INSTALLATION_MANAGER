# returns the version of the given msi-file
function getMSIVersionInfo([IO.FileInfo] $MSI) {
    # tests the path
    if (!(Test-Path $MSI.FullName)) {
        throw "File '{0}' does not exist" -f $MSI.FullName
    }
 
    try {
        # catchs the version of the file
        $windowsInstaller = New-Object -com WindowsInstaller.Installer
        $database = $windowsInstaller.GetType().InvokeMember(
            "OpenDatabase", "InvokeMethod", $Null,
            $windowsInstaller, @($MSI.FullName, 0)
        )
 
        $q = "SELECT Value FROM Property WHERE Property = 'ProductVersion'"
        $View = $database.GetType().InvokeMember(
            "OpenView", "InvokeMethod", $Null, $database, ($q)
        )
 
        $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)
        $record = $View.GetType().InvokeMember( "Fetch", "InvokeMethod", $Null, $View, $Null )
        # catchs the version of the file
        $version = $record.GetType().InvokeMember( "StringData", "GetProperty", $Null, $record, 1 )
 
        return $version
    } catch {
        throw "Failed to get MSI file version: {0}." -f $_
    }
}
Export-ModuleMember -function getMSIVersionInfo