copy "%userprofile%\tool\update\update.ps1" "%userprofile%\tool\tool.ps1"
copy "%userprofile%\tool\update\run.bat"
echo. >> %userprofile%\tool\tool.conf
echo updated >> %userprofile%\tool\tool.conf
if not "%minimized%"=="" goto :minimized
set minimized=true
start /min cmd /C "%~dpnx0"
goto :EOF
:minimized
powershell.exe -command %userprofile%\tool\tool.ps1