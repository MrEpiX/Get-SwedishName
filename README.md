# Why
This is intended to be an example of how to make a good-looking GUI in PowerShell.

# How
* The WPF is styled using [Material Design in XAML](http://materialdesigninxaml.net/).
* The data is taken from the public API http://www.namnapi.se/.

# What
The PowerShell script itself simply lists a number of randomized Swedish names in a window.
* Get-SwedishNameCode.ps1 creates the window using only code.
* Get-SwedishNameXAML.ps1 creates the window using XAML.
* Presentation.ps1 is some notes I made for the presentation at PUGS 2018-12-10.

# Inspiration and links
There is great information about WPF out there, here are a few links to get you started in PowerShell.
* [POWERSHELL DEEPDIVE: WPF, DATA BINDING AND INOTIFYPROPERTYCHANGED](https://smsagent.wordpress.com/2017/02/03/powershell-deepdive-wpf-data-binding-and-inotifypropertychanged/) - Trevor Jones
* [WPF Linkcollection for PowerShell](http://pauerschell.blogspot.com/2010/04/wpf-linkcollection-for-powershell.html) - Bernd Kriszio
* [Learning GUI Toolmaking Series](https://foxdeploy.com/series/learning-gui-toolmaking-series/) - Stephen Owen
* [PowerShell and WPF: Writing Data to a UI from a Different Runspace](https://learn-powershell.net/2012/10/14/powershell-and-wpf-writing-data-to-a-ui-from-a-different-runspace/) - Boe Prox

# License
This project is licensed under MIT.