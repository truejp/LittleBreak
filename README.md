# Little Break

Back in 2021 at the peak of the Covid Pandemic, I was looking for a good solution to make a couple of breaks a day - without loosing that precious green dot in Microsoft Teams and giving myself away to my colleagues (Just kidding, of course..).

This tool includes a simple website with a web installer, to showcase what you can do with just a few very basic powershell scripts. Once you install the script, it will start a "sophisticated" logic that will trick all apps, even teams and the windows screen saver timeout / automatic locking, into thinking that you are still working on the PC. You are done with your little break? No problem, just pick up your mouse and take over!

## Features

This tool showcases a couple of cool features with powershell:

- Download additional payloads from the web
- Create new folder structures
- Automatic Online Self-Update
- Bypassing common safety features
- Controlling user inputs
- Make it start after every reboot
- Some other tricks ;)

## Installing yourself

This script will connect to my own server. You can easily modify the URLs in both powershell and the webpage to make it look like your very own app!

Web Roots are defined in:
- webinstaller.bat in both "Invoke-WebRequest" commands
- update.ps1 in "$global:sourceTree"

To set up your own server, follow these easy instructions (also working with any shared webhosting)
1. Modify the files based on the instructions above
2. Copy "web" folder's contents to your hosting root directory
3. (optional) Enable SSL to get rid of even more safety alerts

Enjoy!

<hr>
Safety note: Powershell is quite powerful. Use this script only for academic purposes. Don't trust scripts that you didnt write / check yourself!