# Anteckningar för PUGS
# http://apikatalogen.se/api - Det finns massor av svenska API:er. Text-TV, Tradera, trafikinfo, slå upp telefonnummer
# http://www.namnapi.se/ - 100 vanligaste tilltals- och efternamnen för svenska män och kvinnor, 20 000 kombinationer

# API call - XML eller JSON
# http://api.namnapi.se/v2/names.json?limit=30

# WPF på olika sätt - XAML eller Kod

# Använder man Visual Studio som designer för sin WPF behöver man ta bort några rader i definitionen för fönstret
# x:Class
# mc:Ignorable="d"

# Det finns också ett par rader som inte behövs
# xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
# xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"

# UI programming behöver flera trådar för att vara responsivt
# Skriver man kod behöver man vara mycket noga med att definiera properties i rätt format, många Controls som används har enums och converters definierade i .NET

<# Material Design style

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