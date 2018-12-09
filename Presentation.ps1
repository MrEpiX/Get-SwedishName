# https://github.com/MrEpiX/Get-SwedishName

# Anteckningar för PUGS
# http://apikatalogen.se/api - Det finns massor av svenska API:er. Text-TV, Tradera, trafikinfo, slå upp telefonnummer
# http://www.namnapi.se/ - 100 vanligaste tilltals- och efternamnen för svenska män och kvinnor, 20 000 kombinationer

# API call - XML eller JSON
# http://api.namnapi.se/v2/names.json?limit=30

# # # # # # # # # # 1 # # # # # # # # # #
# Get-SwedishNameXAML och Get-SwedishNameCode

# WPF på olika sätt - XAML eller Kod

# Använder man Visual Studio som designer för sin WPF behöver man ta bort några rader i definitionen för fönstret
# x:Class
# mc:Ignorable="d"

# Det finns också ett par rader som inte behövs
# xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
# xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"

# UI programming behöver flera trådar för att vara responsivt

# Skriver man kod istället för XAML behöver man vara mycket noga med att definiera properties i rätt format, många controls som används har enums och converters definierade i .NET

# Events via PowerShell läggs till via $control.Add_<Event>{ #Code to run }
# Example: $Button.Add_Click{ Write-Host "Button is clicked!" }

<# Material Design style

Hur får man tag på DLL-erna? Bygg projekt med NuGet-paketet i WPF!

Import-Module "$($PSScriptRoot)\MaterialDesignColors.dll"
Import-Module "$($PSScriptRoot)\MaterialDesignThemes.wpf.dll"

    <Window.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Dark.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Defaults.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignColors;component/Themes/Recommended/Primary/MaterialDesignColor.Lime.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignColors;component/Themes/Recommended/Accent/MaterialDesignColor.DeepPurple.xaml" />
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
    </Window.Resources>

        xmlns:materialDesign="http://materialdesigninxaml.net/winfx/xaml/themes"
        TextElement.Foreground="{DynamicResource MaterialDesignBody}"
        TextElement.FontWeight="Regular"
        TextElement.FontSize="13"
        TextOptions.TextFormattingMode="Ideal" 
        TextOptions.TextRenderingMode="Auto"        
        Background="{DynamicResource MaterialDesignPaper}"
        FontFamily="{DynamicResource MaterialDesignFont}"
#>

# # # # # # # # # # 2 # # # # # # # # # #

# Dispatcher krävs för att uppdatera GUI i annan tråd
# Man behöver då skicka med ett scriptblock i form av en [Action] som är en typ av delegate inom .NET - ett sätt att skriva anonyma metoder
# Man kan skicka med en DispatcherPriority - https://docs.microsoft.com/en-us/dotnet/api/system.windows.threading.dispatcherpriority
# Generellt används "Normal" men man kan använda detta för att ha t.ex en spell checker med lägre prioritet än "Render" som då kan köras under idle time för GUI-tråden
# $syncHash.PopulateButton.Dispatcher.Invoke([Action]{ $syncHash.PopulateButton.Content = "Fixa lite svenska namn, tack!" }, "Normal")

# Mycket svårare att felsöka i andra trådar!

# # # # # # # # # # 3 # # # # # # # # # #

