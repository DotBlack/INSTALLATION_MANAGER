##### ENTRY POINT FOR INSTALLATION PROCESS #####
#Requires -RunAsAdministrator

# get the root directory
# all installation directories are searched relative to the root directory
$rootDirectory = $PSScriptRoot

# ----- IMPORT MODULES -----
$list_installed_software_psm1 = $rootDirectory + "\list_installed_software.psm1"
Import-Module -Name $list_installed_software_psm1
$get_msi_version_info_psm1 = $rootDirectory + "\get_msi_version_info.psm1"
Import-Module -Name $get_msi_version_info_psm1
$get_exe_version_info_psm1 = $rootDirectory + "\get_exe_version_info.psm1"
Import-Module -Name $get_exe_version_info_psm1
$get_version_comparison_psm1 = $rootDirectory + "\version_comparison.psm1"
Import-Module -Name $get_version_comparison_psm1

# ----- LOAD FORMS -----
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.Application]::EnableVisualStyles()

# ----- LOAD IMAGES -----
$imageCheck = [System.Drawing.Image]::Fromfile($rootDirectory + '\Images\Check_20x20.png')
$imageTrash = [System.Drawing.Image]::Fromfile($rootDirectory + '\Images\Trash_20x20.png')
$imageCross = [System.Drawing.Image]::Fromfile($rootDirectory + '\Images\Cross_20x20.png')
$imageInstall = [System.Drawing.Image]::Fromfile($rootDirectory + '\Images\Install_20x20.png')
$imageWarning = [System.Drawing.Image]::Fromfile($rootDirectory + '\Images\Warning_20x20.png')


# ----- CALL INSTALLER ROUTINE -----

# CREATE THE MAIN WINDOW
$form = New-Object System.Windows.Forms.Form
$form.Text = "INSTALLATION MANAGER"
$form.Size = New-Object System.Drawing.Size(1000, 800)
$form.StartPosition = 'CenterScreen'
$form.AutoScale = $false
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.AutoSize = $false
$form.FormBorderStyle = 'FixedSingle'  #Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow, FixedSingle

# CREATE SELECTION TAB
$MainTab = New-Object System.Windows.Forms.TabControl
$MainTab.Size = '970,740'
$MainTab.Location = '10,15'
$MainTab.Multiline = $true
$MainTab.AutoSize = $true
$MainTab.Anchor = 'Top,Left,Bottom,Right'
$form.Controls.Add($MainTab)

# ADD TAB PAGE 1
$TabPage1 = New-Object System.Windows.Forms.TabPage
$Tabpage1.TabIndex = 1
$Tabpage1.Text = 'INSTALLED SOFTWARE'
$TabPage1.Name = 'Tab1'
$tabPage1.AutoScroll = $true
$MainTab.Controls.AddRange(@($TabPage1))


# TRASH BUTTON - USED TO DEINSTALL SOFTWARE
function Trash_Button_Click($id) {
    # data catched from the os (uninstall paths)
    $installed_software_uninstall_paths = @()
    $installed_software_uninstall_paths = list_installed_software\getInstalledSoftwareUninstallPaths
    # get the deinstall path
    $DefaultPath = [string]$installed_software_uninstall_paths[$id]
    # restore path -> converts to string
    $DefaultPath = $DefaultPath.Substring(0, $DefaultPath.Length - 1)
    # get the index on first sequence of .exe and offset by 4
    $index = $DefaultPath.LastIndexOf(".exe") + 4
    # if the sequence is less then 3 it means nothing was found
    if ($index -eq 3) {
        # try with .EXE instead
        $index = $DefaultPath.LastIndexOf(".EXE") + 4
    }
    # get the deinstall exe file
    $FilePath0 = $DefaultPath.Substring(0, $index)
    # get the deinstall arguments
    $FilePath1 = $DefaultPath.Substring($index + 1, $DefaultPath.Length - 1 - $index)

    # replace not needed characters
    $FilePath0 = $FilePath0 -Replace """", ""
    # replace not needed characters
    $FilePath1 = $FilePath1 -Replace """", ""
    # start the deinstall file
    Start-Process -FilePath $FilePath0 -ArgumentList $FilePath1 -Wait

    # rebuild the page of installed software
    RebuildTab1
    # rebuild the page of software to install
    RebuildTab2
}

# REBUILDS THE PAGE OF INSTALLED SOFTWARE
function RebuildTab1() {
    # clear page 1
    $TabPage1.Controls.Clear()

    # --- scope based containers ---
    # stored labels
    $labelsInstalled = @()
    # stored boxes with checkmark
    $pictureBoxesCheck = @()
    # stored boxes with trashbutton
    $pictureBoxesTrash = @()

    # data catched from the os (display names)
    $installed_software_display_names = @()
    $installed_software_display_names = list_installed_software\getInstalledSoftwareListDisplayNames
    # data catched from the os (display versions)
    $installed_software_display_versions = @()
    $installed_software_display_versions = list_installed_software\getInstalledSoftwareListDisplayVersions

    # loop over all the installed software-modules
    for ($i = 0; $i -lt $installed_software_display_names.Length; $i++) {

        # creates the text-label
        $LabelInstalledPositionX = 10;
        $LabelInstalledPositionY = 20 + $i * 40;
        $labelsInstalled += New-Object System.Windows.Forms.Label
        $labelsInstalled[$labelsInstalled.length - 1].Location = New-Object System.Drawing.Point($LabelInstalledPositionX, $LabelInstalledPositionY)
        $labelsInstalled[$labelsInstalled.length - 1].Size = New-Object System.Drawing.Size(800, 20)
        $labelsInstalled[$labelsInstalled.length - 1].MaximumSize = New-Object System.Drawing.Size(800, 20)
        $labelText = $installed_software_display_names.Get($i) + " - " + $installed_software_display_versions.Get($i)
        $labelText = $labelText.Replace("`n", "")
        $labelsInstalled[$labelsInstalled.length - 1].Text = $labelText
        $labelsInstalled[$labelsInstalled.length - 1].Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Regular)
        $labelsInstalled[$labelsInstalled.length - 1].ForeColor = [System.Drawing.Color]::Black
        $labelsInstalled[$labelsInstalled.length - 1].BackColor = [System.Drawing.Color]::LightGreen
        $TabPage1.Controls.AddRange(@($labelsInstalled[$labelsInstalled.length - 1]))

        # creates the boxes with checkmark
        $PictureBoxCheckPositionX = 830;
        $PictureBoxCheckPositionY = 20 + $i * 40;
        $pictureBoxesCheck += new-object Windows.Forms.PictureBox
        $pictureBoxesCheck[$pictureBoxesCheck.length - 1].Location = New-Object System.Drawing.Point($PictureBoxCheckPositionX, $PictureBoxCheckPositionY)
        $pictureBoxesCheck[$pictureBoxesCheck.length - 1].Width = $imageCheck.Size.Width
        $pictureBoxesCheck[$pictureBoxesCheck.length - 1].Height = $imageCheck.Size.Height
        $pictureBoxesCheck[$pictureBoxesCheck.length - 1].Image = $imageCheck
        $TabPage1.controls.AddRange(@($pictureBoxesCheck[$pictureBoxesCheck.length - 1]))

        # creates the boxes with trashbutton
        $PictureBoxTrashPositionX = 880;
        $PictureBoxTrashPositionY = 20 + $i * 40;
        $pictureBoxesTrash += new-object System.Windows.Forms.Button
        $pictureBoxesTrash[$pictureBoxesTrash.length - 1].Location = New-Object System.Drawing.Point($PictureBoxTrashPositionX, $PictureBoxTrashPositionY)
        $pictureBoxesTrash[$pictureBoxesTrash.length - 1].Width = $imageTrash.Size.Width + 2
        $pictureBoxesTrash[$pictureBoxesTrash.length - 1].Height = $imageTrash.Size.Height + 2
        $pictureBoxesTrash[$pictureBoxesTrash.length - 1].Image = $imageTrash
        $pictureBoxesTrash[$pictureBoxesTrash.length - 1].Name = $i
        $pictureBoxesTrash[$pictureBoxesTrash.length - 1].Add_Click({ Trash_Button_Click($($this.Name)) })
        $TabPage1.controls.AddRange(@($pictureBoxesTrash[$pictureBoxesTrash.length - 1]))
    }
}

### ---- INITIAL PAGE BUILD ---- ###
RebuildTab1
### --- --- --- --- --- --- --- ###


# ----- SOFTWARE TO INSTALL -----

# ADD TAB PAGE 2
$TabPage2 = New-Object System.Windows.Forms.TabPage
$Tabpage2.TabIndex = 2
$Tabpage2.Text = 'INSTALLATIONS / UPDATES AVAILABLE'
$TabPage2.Name = 'Tab2'
$MainTab.Controls.AddRange(@($TabPage2))


# --- Data from .CSV ---
$installer_id = @()
$installer_files = @()
$installer_names = @()
$installer_types = @()
$installer_powershell_files = @()

# Import the Default_Software_List
$Default_Software_List = Import-Csv -Path ($rootDirectory + "\Configuration\_Default_Software_List.csv") -Header 'ID', 'INSTALL FILE PATH', 'SOFTWARE DISPLAY NAME', 'INSTALLER TYPE', 'INSTALL POWERSHELL PATH'

# load the configured csv-file
for($si = 1; $si -lt $Default_Software_List.Length; $si++)
{
    $installer_id += [string]$Default_Software_List[$si].'ID'
    $installer_files += [string]$Default_Software_List[$si].'INSTALL FILE PATH'
    $installer_names += [string]$Default_Software_List[$si].'SOFTWARE DISPLAY NAME'
    $installer_types += [string]$Default_Software_List[$si].'INSTALLER TYPE'
    $installer_powershell_files += [string]$Default_Software_List[$si].'INSTALL POWERSHELL PATH'
}

# --- Data from .CSV END --- 

# INSTALL BUTTON - USED TO INSTALL SOFTWARE
function Install_Button_Click($id) {
    # call the powershell-file for the installation as admin
    $powerShellFile = $installer_powershell_files[$id]
    & $powerShellFile -Verb RunAs
    # rebuild the page of installed software
    RebuildTab1
    # rebuild the page of software to install
    RebuildTab2
}


# REBUILDS THE PAGE OF SOFTWARE TO INSTALL
function RebuildTab2() {
    # clear page 2
    $TabPage2.Controls.Clear()

    # --- scope based containers ---
    # stored labels
    $labelsToInstall = @()
    # stored boxes with crossmarks
    $pictureBoxesCross = @()
    # stored boxes with installbuttons
    $pictureBoxesInstall = @()

    # --- collected containers - software to install ---
    # software (names) to install
    $SoftwareToInstall_DisplayNames = @()
    # software (displayVersions) to install
    $SoftwareToInstall_DisplayVersions = @()
    # software (isAUpdate) to install
    $SoftwareToInstall_IsAUpdate = @()
    # software (defaultIndex) to install
    $SoftwareToInstall_DefaultIndex = @()

    # loop over all the installed software-modules
    for ($inst = 0; $inst -lt $installer_names.Length; $inst++) {
        # installer version container
        $installer_version

        # get the MSI version
        if($installer_types[$inst] -eq "MSI" -or $installer_types[$inst] -eq "msi")
        {
        # ---- for MSI files ----
        # get the installer-version
        $installer_version = get_msi_version_info\getMSIVersionInfo($installer_files[$inst])
        # get the index 1 of the array and trim it
        $installer_version = $installer_version[1].Trim()
        }

        # get the EXE version
        if($installer_types[$inst] -eq "EXE" -or $installer_types[$inst] -eq "exe")
        {
        # ---- for EXE files ----
        # get the installer-version
        $installer_version = get_exe_version_info\getEXEVersionInfo($installer_files[$inst])

        # -- get the installed version of the software -- 
        $check_if_installed = list_installed_software\hasSoftwareInstalled($installer_names[$inst])
        }

        # check if the software is already installed
        if ($check_if_installed -eq $true) {
            # get the installed version
            $installed_version = list_installed_software\getSoftwareInstalledVersion($installer_names[$inst])
            # get the installed name
            $installed_name = list_installed_software\getSoftwareInstalledDisplayName($installer_names[$inst])
            # get the index in the array
            $installed_index = list_installed_software\getInstalledSoftwareIndex($installer_names[$inst])
        
            #check if we need to update the software (newer version)
            $need_to_update = version_comparison\get_need_to_update_status -version_installpackage $installer_version -version_installed $installed_version

            # record the new entry
            if ($need_to_update -eq $true) {
                # record the installation
                $SoftwareToInstall_DisplayNames += $installer_names[$inst]
                $SoftwareToInstall_DisplayVersions += $installer_version
                $SoftwareToInstall_DefaultIndex += $inst
                # mark the record as an update
                $SoftwareToInstall_IsAUpdate += $true
            }
        }
        # make straight a install option entry
        else {
            # record the installation
            $SoftwareToInstall_DisplayNames += $installer_names[$inst]
            $SoftwareToInstall_DisplayVersions += $installer_version
            $SoftwareToInstall_DefaultIndex += $inst
            # mark the record as a new installation
            $SoftwareToInstall_IsAUpdate += $false
        }
    }

    # NOTHING TO UPDATE / INSTALL LABEL
    if ($SoftwareToInstall_DisplayNames.Length -eq 0) {
        $nothingToInstallLabel = New-Object System.Windows.Forms.Label
        $nothingToInstallLabel.Location = New-Object System.Drawing.Point(10, 30)
        $nothingToInstallLabel.Size = New-Object System.Drawing.Size(800, 20)
        $nothingToInstallLabel.Text = "... YOU ARE GOOD TO GO ...`nYOUR INSTALLATIONS ARE UP TO DATE`nNOTHAING AVAILABLE TO INSTALL FOR YOU`n:)"
        $nothingToInstallLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $nothingToInstallLabel.ForeColor = [System.Drawing.Color]::Black
        $nothingToInstallLabel.BackColor = [System.Drawing.Color]::LightSeaGreen
        $nothingToInstallLabel.AutoSize = $true
        $nothingToInstallLabel.TextAlign = 'MiddleCenter'
        $nothingToInstallLabel.Left = ($Tabpage2.Width / 2 - $nothingToInstallLabel.Width / 4)
        $nothingToInstallLabel.Top = 60
        $TabPage2.Controls.AddRange(@($nothingToInstallLabel))
    }

    # loop over all the software-modules to install
    for ($i = 0; $i -lt $SoftwareToInstall_DisplayNames.Length; $i++) {

        # creates the install-labels
        $LabelToInstalledPositionX = 10;
        $LabelToInstalledPositionY = 20 + $i * 40;
        $labelsToInstall += New-Object System.Windows.Forms.Label
        $labelsToInstall[$labelsToInstall.length - 1].Location = New-Object System.Drawing.Point($LabelToInstalledPositionX, $LabelToInstalledPositionY)
        $labelsToInstall[$labelsToInstall.length - 1].Size = New-Object System.Drawing.Size(800, 20)
        $labelsToInstall[$labelsToInstall.length - 1].MaximumSize = New-Object System.Drawing.Size(800, 20)
        $labelText = $SoftwareToInstall_DisplayNames.Get($i) + " - " + $SoftwareToInstall_DisplayVersions.Get($i)
        $labelText = $labelText.Replace("`n", "")
        $labelsToInstall[$labelsToInstall.length - 1].Text = $labelText
        $labelsToInstall[$labelsToInstall.length - 1].Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Regular)
        $labelsToInstall[$labelsToInstall.length - 1].ForeColor = [System.Drawing.Color]::Black
        if ($SoftwareToInstall_IsAUpdate[$i] -eq $true) {
            #is just a update..
            $labelsToInstall[$labelsToInstall.length - 1].BackColor = [System.Drawing.Color]::Yellow
        }
        else {
            #.. no update - new installation
            $labelsToInstall[$labelsToInstall.length - 1].BackColor = [System.Drawing.Color]::IndianRed
        }
        $TabPage2.Controls.AddRange(@($labelsToInstall[$labelsToInstall.length - 1]))

        # creates the boxes with crossmarks
        $PictureBoxCrossPositionX = 830;
        $PictureBoxCrossPositionY = 20 + $i * 40;
        $pictureBoxesCross += new-object Windows.Forms.PictureBox
        $pictureBoxesCross[$pictureBoxesCross.length - 1].Location = New-Object System.Drawing.Point($PictureBoxCrossPositionX, $PictureBoxCrossPositionY)
        if ($SoftwareToInstall_IsAUpdate[$i] -eq $true) {
            #is just a update..
            $pictureBoxesCross[$pictureBoxesCross.length - 1].Width = $imageWarning.Size.Width
            $pictureBoxesCross[$pictureBoxesCross.length - 1].Height = $imageWarning.Size.Height
            $pictureBoxesCross[$pictureBoxesCross.length - 1].Image = $imageWarning
        }
        else {
            #.. no update - new installation
            $pictureBoxesCross[$pictureBoxesCross.length - 1].Width = $imageCross.Size.Width
            $pictureBoxesCross[$pictureBoxesCross.length - 1].Height = $imageCross.Size.Height
            $pictureBoxesCross[$pictureBoxesCross.length - 1].Image = $imageCross
        }
        $TabPage2.controls.AddRange(@($pictureBoxesCross[$pictureBoxesCross.length - 1]))

        # creates the boxes with installbutton
        $PictureBoxInstallPositionX = 880;
        $PictureBoxInstallPositionY = 20 + $i * 40;
        $pictureBoxesInstall += new-object System.Windows.Forms.Button
        $pictureBoxesInstall[$pictureBoxesInstall.length - 1].Location = New-Object System.Drawing.Point($PictureBoxInstallPositionX, $PictureBoxInstallPositionY)
        $pictureBoxesInstall[$pictureBoxesInstall.length - 1].Width = $imageInstall.Size.Width + 2
        $pictureBoxesInstall[$pictureBoxesInstall.length - 1].Height = $imageInstall.Size.Height + 2
        $pictureBoxesInstall[$pictureBoxesInstall.length - 1].Image = $imageInstall
        $pictureBoxesInstall[$pictureBoxesInstall.length - 1].Name = $SoftwareToInstall_DefaultIndex[$i]
        $pictureBoxesInstall[$pictureBoxesInstall.length - 1].Add_Click({ Install_Button_Click($($this.Name)) })
        $TabPage2.controls.AddRange(@($pictureBoxesInstall[$pictureBoxesInstall.length - 1]))
    }
}

### ---- INITIAL PAGE BUILD ---- ###
RebuildTab2
### --- --- --- --- --- --- --- ###


# ADD TAB PAGE 3
$TabPage3 = New-Object System.Windows.Forms.TabPage
$Tabpage3.TabIndex = 2
$Tabpage3.Text = 'PREDEFINED INSTALLATION SETS'
$TabPage3.Name = 'Tab3'
$MainTab.Controls.AddRange(@($TabPage3))

# ADD TAB PAGE 4
$TabPage4 = New-Object System.Windows.Forms.TabPage
$Tabpage4.TabIndex = 2
$Tabpage4.Text = 'ABOUT'
$TabPage4.Name = 'Tab4'
$MainTab.Controls.AddRange(@($TabPage4))

# creates the copyright-label
$copyrightLabel1 = New-Object System.Windows.Forms.Label
$copyrightLabel1.Location = New-Object System.Drawing.Point(10, 30)
$copyrightLabel1.Size = New-Object System.Drawing.Size(800, 20)
$copyrightLabel1.Text = "INSTALL MANAGER`n`nA product created by https://github.com/DotBlack`n`n© All rights reserved"
$copyrightLabel1.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$copyrightLabel1.ForeColor = [System.Drawing.Color]::Black
$copyrightLabel1.BackColor = [System.Drawing.Color]::White
$copyrightLabel1.AutoSize = $true
$copyrightLabel1.TextAlign = 'MiddleCenter'
$copyrightLabel1.Left = ($Tabpage4.Width / 2 - $copyrightLabel1.Width / 4)
$copyrightLabel1.Top = 60
$TabPage4.Controls.AddRange(@($copyrightLabel1))


# ----- ACTIVATE THE CREATED FORM -----
$Form.Add_Shown({ $Form.Activate() })
[void] $Form.ShowDialog()
### --- --- --- --- --- --- --- --- ###

# ----------- REMOVE MODULES -----------
Remove-Module -Name "get_msi_version_info"
Remove-Module -Name "get_exe_version_info"
Remove-Module -Name "list_installed_software"
Remove-Module -Name "version_comparison"
### --- --- --- --- --- --- --- --- ###