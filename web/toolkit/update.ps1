### Standard imports and global values ###
set-executionpolicy -executionpolicy bypass -scope Currentuser
Add-Type -assembly System.Windows.Forms
$global:active = $false
$global:threshold = 30
$global:activeBoot = $false
$global:version = 0
$global:sourceTree = "https://www.pixel-shift.de/take-a-break/toolkit"

################### Pause active ####################
#### Job1: Listener when active                  ####
#### Job2: Action Sim                            ####
#### KeyState: get last Keyboard input           ####
#####################################################

function DelExpired {
$path = "~\tool\expired.file"
if (Test-Path -Path $path){
    Remove-item $path
}
}

function Pause {
$flags = @($global:threshold, "1", $global:trigger)
Start-Job -Name KeyState -ScriptBlock{
Add-Type -assembly System.Windows.Forms
$d = get-date
$lastEntry = $d.TimeOfDay.TotalSeconds
$triggered = $false
$signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

### load signatures and make members available ###
$API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru
    try {
        while ($true) {
        $d = get-date
        if (($lastEntry + $args[0]) -lt $d.TimeOfDay.TotalSeconds){
            if (!$triggered) {
                $triggered = $true
                ##### create checkfile #####
                $path = "~\tool\expired.file"
                if (!(Test-Path -Path $path)){
                    New-item -Path "~\tool\" -Name "expired.file" -ItemType "file" -Value "Content"
                }
            }
        }
        if (!(($lastEntry + $args[0]) -lt $d.TimeOfDay.TotalSeconds) -and $triggered) {
             $triggered = $false
             ##### delete checkfile #####
             $path = "~\tool\expired.file"
             if (Test-Path -Path $path){
                 Remove-item $path
             }
        }
        Start-Sleep -Milliseconds 40
		for ($ascii = 9; $ascii -le 254; $ascii++) {
			$state = $API::GetAsyncKeyState($ascii)
			if ($state -eq -32767) {
                $d = get-date
                $lastEntry = $d.TimeOfDay.TotalSeconds               
			}
		}
	}
    }
    finally {
        Write-Host "Done."
    }
} -ArgumentList $flags

Start-Job -Name Job1 -ScriptBlock{
set-executionpolicy -executionpolicy bypass -scope Currentuser
Add-Type -AssemblyName System.Windows.Forms

function Perform {
	param (
    [Parameter(Mandatory=$True,Position=1)]
    [string]
    $ApplicationTitle,

    [Parameter(Mandatory=$True,Position=2)]
    [string]
    $Keys,

    [Parameter(Mandatory=$false)]
    [int] $WaitTime
    )
[void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class StartActivateProgramClass {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
    }
"@
$p = Get-Process | Where-Object { $_.MainWindowTitle -eq $ApplicationTitle }
if ($p) 
{
    $h = $p[0].MainWindowHandle
    [void] [StartActivateProgramClass]::SetForegroundWindow($h)
    [System.Windows.Forms.SendKeys]::SendWait($Keys)
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.SendKeys]::SendWait("{BS}")
    if ($WaitTime)
    {
        Start-Sleep -Seconds $WaitTime
    }
}
}
$launched = $false
while ($true) {
    ### Check System Input ###
    $Pos1 = [System.Windows.Forms.Cursor]::Position
    for($i = 0; $i -lt $args[0]; $i++){  
	    $Pos11 = [System.Windows.Forms.Cursor]::Position   
        Start-Sleep -Milliseconds 500
	    $Pos12 = [System.Windows.Forms.Cursor]::Position
        if (!(($Pos11.X -eq $Pos12.X) -and ($Pos11.Y -eq $Pos12.Y) -and (Test-Path -Path "~\tool\expired.file"))) {
        break
        }
    }
    if (Get-Job -Name KeyExpiredJobI){
        $result = [System.Windows.Forms.MessageBox]::Show("Job found", "Notification", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
    }
    $Pos2 = [System.Windows.Forms.Cursor]::Position
	if (($Pos1.X -eq $Pos2.X) -and ($Pos1.Y -eq $Pos2.Y) -and (Test-Path -Path "~\tool\expired.file")) {
		### launch applet if not already launched ###
		if ($launched -eq $false){
			Start-Job -Name Job2 -ScriptBlock{
			### launch it ###
			Add-Type -assembly System.Windows.Forms
			$second_form = New-Object System.Windows.Forms.Form
			$second_form.Text ='Activity Sim by Philipp Lehnet'
			$second_form.Width = 220
			$second_form.Height = 90
			$second_form.AutoSize = $false
			
			$Label = New-Object System.Windows.Forms.Label
			$Label.Text = "Rest well, dear Friend :)"
			$Label.Location  = New-Object System.Drawing.Point(0,5)
			$Label.AutoSize = $true
			
			$textBox = New-Object System.Windows.Forms.TextBox
			$textBox.Location = New-Object System.Drawing.Point(150,10)
			$textBox.Size = New-Object System.Drawing.Size(50,20)
			
			$second_form.Controls.Add($textBox)
			$second_form.Controls.Add($Label)
			$second_form.ShowDialog()
			}
			$launched = $true
		}
		### Perform full User-Activity sim ###
		Perform -ApplicationTitle "Activity Sim by Philipp Lehnet" -Keys $args[1]
        $x = ($pos1.X) + 8
		$y = ($pos1.Y) + 8
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
        Start-Sleep -Milliseconds 200
        $x = ($pos1.X)
		$y = ($pos1.Y)
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
	}
	else {
		if ($launched -eq $true) {
		get-process | where-object {$_.MainWindowTitle -eq "Activity Sim by Philipp Lehnet"} | stop-process
		Stop-Job -Name "Job2"
        Stop-Job -Name "KeyState"
        DelExpired
		$launched = $false
		}
		### close applet if not already closed ###
	}
}
} -ArgumentList $flags
}

#############################
### End of Function-Block ###
#############################

################## Load config, initialize Tool #################

### clean update & env history ###

$path = $PSScriptRoot + "\update"
if (!(Test-Path -Path $path)){
    New-item -Path $PSScriptRoot -Name "update" -ItemType "directory"
}

$path = "~\tool\expired.file"
if (Test-Path -Path $path){
    Remove-item $path
}

$issue  = $false
$path = $PSScriptRoot + "\tool.conf"
if (!(Test-Path -Path $path)){
	Write-Host 'File not found!'
    $val = "boot:False
threshold:30
version:0"
	New-item -Path $PSScriptRoot -Name "tool.conf" -ItemType "file" -Value $val
    Start-Sleep -Milliseconds 500
}

(gc $path) | ? {$_.trim() -ne "" } | set-content $path
$configFile = (Get-Content $path).Split([Environment]::NewLine)

if (!$configFile[2]){
    $issue = $true
    Write-Host "Invalid config. Set default values."
}
else {
if ($configFile[0] -eq 'boot:True'){
	$global:active = $true
    $global:activeBoot = $true
	Write-Host 'Default: Active'
}
elseif ($configFile[0] -eq 'boot:False') {
	$global:active = $false
    $global:activeBoot = $false
	Write-Host 'Default: Inactive'
}
else {
	$global:active = $false
    $global:activeBoot = $true
	$issue = $true
}

if ($configFile[1].Contains("threshold")){
	$help = $configFile[1] -split ":"
	$global:threshold = $help[1]
}
else {
	$issue = $true
	$global:threshold = 30
}

if ($configFile[3]){
if ($configFile[3].Contains("updated")){
    $vPath = $PSScriptRoot + "\version.txt"
    $vFile= (Get-Content $vPath).Split([Environment]::NewLine)
    $help = $vFile[0] -split ":"
    $global:version = $help[1]
    Write-Host "Tool has been updated."
    $val = "boot:" + $global:active + "
threshold:" + $global:threshold + "
version:" + $global:version
Set-Content -Path $path -Value $val
$result = [System.Windows.Forms.MessageBox]::Show("Update has been installed! The new Version is " + $global:version, "Update finished", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
$path = $PSScriptRoot + "\update\changelog.txt"
Start notepad $path
}
}
else {

if ($configFile[2].Contains("version")){
	$help = $configFile[2] -split ":"
	$global:version = $help[1]
}
else {
	$issue = $true
}
}
}
if ($issue) {
$val = "boot:" + $global:active + "
threshold:30
version:0"
Set-Content -Path $path -Value $val
Write-Host "Default values set."
}


###########################
### Update notification ###
###########################


$path = $PSScriptRoot + "\version.txt"
if (Test-Path -Path $path){
    Remove-Item $path
}
    $dPath = $global:sourceTree + "/version.txt"
    Invoke-WebRequest $dPath -OutFile $Path
    $newVersion = 0
    if (!(Test-Path -Path $Path)){
	Write-Host 'No update file!'
    }
    else{
    $versionFile = (Get-Content $Path).Split([Environment]::NewLine)
    if (!$versionFile[2]){
    Write-Host "Invalid File. Please contact admin."
    }
    else {
        if ($versionFile[0].Contains("version")){
	    $help = $versionFile[0] -split ":"
	    $newVersion = $help[1]
    }
    }
    if ($newVersion -gt $global:Version) {
       $result = [System.Windows.Forms.MessageBox]::Show("A more recent version of this tool is available. Please install the update!", "Update available", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
       }
}


### create form ###
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Little Break by Philipp Lehnet'
$main_form.Width = 250
$main_form.Height = 170
$main_form.AutoSize = $false
$main_form.ControlBox = $False


### create GUI elements ###
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Activation after " + $global:threshold + " seconds."
$Label.Location  = New-Object System.Drawing.Point(5,0)
$Label.AutoSize = $true

$Label2 = New-Object System.Windows.Forms.Label
$Label2.Location  = New-Object System.Drawing.Point(5,23)
$Label2.AutoSize = $true

$Label3 = New-Object System.Windows.Forms.Label
$Label3.Text = "Version " + $global:version
$Label3.Location  = New-Object System.Drawing.Point(150,95)
$Label3.AutoSize = $true

$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(100,20)
$Button.Size = New-Object System.Drawing.Size(120,23)

$Settings = New-Object System.Windows.Forms.Button
$Settings.Location = New-Object System.Drawing.Size(5,60)
$Settings.Size = New-Object System.Drawing.Size(100,23)
$Settings.Text = "Settings"

$Update = New-Object System.Windows.Forms.Button
$Update.Location = New-Object System.Drawing.Size(120,60)
$Update.Size = New-Object System.Drawing.Size(100,23)
$Update.Text = "Search for Updates"

$Hide = New-Object System.Windows.Forms.Button
$Hide.Location = New-Object System.Drawing.Size(5,90)
$Hide.Size = New-Object System.Drawing.Size(55,23)
$Hide.Text = "Hide"

$StopUsage = New-Object System.Windows.Forms.Button
$StopUsage.Location = New-Object System.Drawing.Size(70,90)
$StopUsage.Size = New-Object System.Drawing.Size(55,23)
$StopUsage.Text = "Exit"

if($global:active -eq $true){
    $Button.Text = "Disable"
    $Label2.Text = "Status: active"
    $Label2.ForeColor = "Green"
    Pause
}
else {
    $Label2.Text = "Status: inactive"
    $Label2.ForeColor = "Red"
    $Button.Text = "Enable"
}

#### create listeners ####

$Button.Add_Click({
if ($global:active -eq $true){
	$Label2.Text =  "Status: inactive"
    $Label2.ForeColor = "Red"
	$Button.Text = "Enable"
	$global:active = $false
	$main_form.Show()
	Stop-Job -Name "Job1"
    Stop-Job -Name "KeyState"
    DelExpired
}
else {
	$Label2.Text =  "Status: active"
    $Label2.ForeColor = "Green"
	$Button.Text = "Disable"
	$global:active = $true
	$main_form.Show()
	Pause
}
})

$Hide.Add_Click({
$main_form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
})

$StopUsage.Add_Click({
$result = [System.Windows.Forms.MessageBox]::Show("Tool is going to stop execution. You are no longer protected.", "Execution stopped", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
Stop-Job -Name "Job1"
Stop-Job -Name "Job2"
Stop-Job -Name "KeyState"
DelExpired
$main_form.Close()
})

$Update.Add_Click({
	### manually search for new updates ###
    ### wipe previous updates ###
    $uPath = $PSScriptRoot + "\version.txt"
    if (Test-Path -Path $uPath){
        Remove-Item $uPath
    }
	### fetch information from BL Update Server ###
    $dPath = $global:sourceTree + "/version.txt"
    Invoke-WebRequest $dPath -OutFile $uPath
    $newVersion = 0
    $issue  = $false
    if (!(Test-Path -Path $uPath)){
	Write-Host 'No update file!'
    $result = [System.Windows.Forms.MessageBox]::Show("No connection to the Update File-Server.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
    }
    else{
    $versionFile = (Get-Content $uPath).Split([Environment]::NewLine)
    if (!$versionFile[2]){
    $issue = $true
    Write-Host "Invalid File. Please contact admin."
    }
    else {
        if ($versionFile[0].Contains("version")){
	    $help = $versionFile[0] -split ":"
	    $newVersion = $help[1]
    }
    else {
        $issue = $true
    }
    }

    if ($issue){
    $result = [System.Windows.Forms.MessageBox]::Show("An Error occured during the Update. Please try again later.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
    }
    else {
        if ($newVersion -gt $global:Version) {
            ### Update notification ###
            $result = [System.Windows.Forms.MessageBox]::Show("A more recent version of this tool is available. The update will be installed immediately!", "Update available", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
            installUpdate
        }
        else {
            $result = [System.Windows.Forms.MessageBox]::Show("You are up to date!", "No Update available", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
        }
    }
}

})


function installUpdate {
    ### fetch update-pack from BL Sourcetree ###
    $uPath = $PSScriptRoot + "\update\helper.bat"
    $dPath = $global:sourceTree + "/helper.bat"
    Invoke-WebRequest $dPath -OutFile $uPath
    if (!(Test-Path -Path $uPath)){
    $result = [System.Windows.Forms.MessageBox]::Show("[Server Issue] File not found: " + $dPath, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
    break;
    }
    $uPath = $PSScriptRoot + "\update\update.ps1"
    $dPath = $global:sourceTree + "/update.ps1"
    Invoke-WebRequest $dPath -OutFile $uPath
    if (!(Test-Path -Path $uPath)){
    $result = [System.Windows.Forms.MessageBox]::Show("[Server Issue] File not found: " + $dPath, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
    break;
    }
    $uPath = $PSScriptRoot + "\update\changelog.txt"
    $dPath = $global:sourceTree + "/changelog.txt"
    Invoke-WebRequest $dPath -OutFile $uPath
    if (!(Test-Path -Path $uPath)){
    $result = [System.Windows.Forms.MessageBox]::Show("[Server Issue] File not found: " + $dPath, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
    break;
    }
    $uPath = $PSScriptRoot + "\update\run.bat"
    $dPath = $global:sourceTree + "/run.bat"
    Invoke-WebRequest $dPath -OutFile $uPath
    if (!(Test-Path -Path $uPath)){
    $result = [System.Windows.Forms.MessageBox]::Show("[Server Issue] File not found: " + $dPath, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
    break;
    }
    
    ### backup old files from previous version ###
    $path = $PSScriptRoot + "/backup"
    if (!(Test-Path -Path $path)){
	    New-item -Path $PSScriptRoot -Name "backup" -ItemType "directory"
        Start-Sleep -Milliseconds 500
    }
    $path = $PSScriptRoot + "/tool.ps1"
    $tPath = $PSScriptRoot + "/backup/tool.ps1"
    Copy-Item $path -Destination $tPath

    $path = $PSScriptRoot + "/tool.conf"
    $tPath = $PSScriptRoot + "/backup/tool.conf"
    Copy-Item $path -Destination $tPath

    $path = $env:APPDATA + "/Microsoft\Windows\Start Menu\Programs\Startup\run.bat"
    $tPath = $PSScriptRoot + "/backup/run.bat"
    Copy-Item $path -Destination $tPath

    ### stop all pending tasks ###
    Stop-Job -Name "Job1"
    Stop-Job -Name "Job2"
    Stop-Job -Name "KeyState"
    DelExpired
    ### launch update helper ###
    $helperPath = $PSScriptRoot + "\update\helper.bat"
    start-process $helperPath
    ### close form ###
    $main_form.Close()
}



############# Settings #############

$Settings.Add_Click({

$settings_form = New-Object System.Windows.Forms.Form
$settings_form.Text ='Settings'
$settings_form.Width = 220
$settings_form.Height = 130
$settings_form.AutoSize = $false
		
$SaveLabel = New-Object System.Windows.Forms.Label
$SaveLabel.Text = "System active after"
$SaveLabel.Location  = New-Object System.Drawing.Point(0,5)
$SaveLabel.AutoSize = $true

$activeStart = new-object System.Windows.Forms.checkbox
$activeStart.Location = new-object System.Drawing.Size(5,25)
$activeStart.Size = new-object System.Drawing.Size(250,30)
$activeStart.Text = "Active by default"

if($global:activeBoot -eq $true){
    $activeStart.Checked = $true
}
else {
    $activeStart.Checked = $false
}

$global:NewDuration = New-Object System.Windows.Forms.ComboBox
$global:NewDuration.Location  = New-Object System.Drawing.Point(100,0)
$global:NewDuration.Width = 50
$global:NewDuration.Items.Add("15")
$global:NewDuration.Items.Add("30")
$global:NewDuration.Items.Add("60")
$global:NewDuration.Items.Add("90")
$global:NewDuration.Items.Add("120")
$global:NewDuration.Items.Add("240")
$global:NewDuration.Items.Add("300")

### set correct value ###
ForEach ($ComboBoxItem in $global:NewDuration.Items) {
  If ($ComboBoxItem -eq $global:threshold) {
     $CorrectComboBoxItem = $ComboBoxItem
  }
}
$global:NewDuration.SelectedIndex = $global:NewDuration.Items.IndexOf($CorrectComboBoxItem)
$Save = New-Object System.Windows.Forms.Button
$Save.Location = New-Object System.Drawing.Size(0,55)
$Save.Size = New-Object System.Drawing.Size(100,23)
$Save.Text = "Save"


$Save.Add_Click({
$global:threshold = [int] $global:NewDuration.SelectedItem
$global:activeBoot = $activeStart.Checked
ConfUp
$result = [System.Windows.Forms.MessageBox]::Show("Your settings were all saved.", "Update successful", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::None)
$settings_form.Close()
})

$settings_form.Controls.Add($activeStart)
$settings_form.Controls.Add($SaveLabel)
$settings_form.Controls.Add($Save)
$settings_form.Controls.Add($global:NewDuration)
$settings_form.ShowDialog()
})


### Update Config ###
function ConfUp {
$val = "boot:" + $global:activeBoot + "
threshold:" + $global:threshold + "
version:" + $global:version
$path = $PSScriptRoot + "\tool.conf"
Set-Content -Path $path -Value $val
$Label.Text = "Activation after " + $global:threshold + " seconds."
if($global:active){
    if ($launched -eq $true) {
        get-process | where-object {$_.MainWindowTitle -eq "Activity Sim by Philipp Lehnet"} | stop-process
		Stop-Job -Name "Job2"
    }
    Stop-Job -Name "Job1"
    DelExpired
    Pause
}
}

############## Initial Launch #################

$main_form.Controls.Add($Button)
$main_form.Controls.Add($Settings)
$main_form.Controls.Add($Hide)
$main_form.Controls.Add($StopUsage)
$main_form.Controls.Add($Label)
$main_form.Controls.Add($Label2)
$main_form.Controls.Add($Label3)
$main_form.Controls.Add($Update)
$main_form.ShowDialog()