# returns the version of the given exe-file
function getEXEVersionInfo($EXE) {
    # tests the path
    $pathTest = Test-Path -Path $EXE
    if ($pathTest -eq $false) {
        throw "File '{0}' does not exist" -f $EXE
    }
    try {
        # catchs the version of the file
        $version = (Get-Command $EXE).FileVersionInfo.FileVersion
        return $version
    } catch {
        throw "Failed to get EXE file version: {0}." -f $_
    }
}
Export-ModuleMember -function getEXEVersionInfo