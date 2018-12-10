# Include assembly PresentationFramework to be able to create WPF app
Add-Type -AssemblyName PresentationFramework

Import-Module "$($PSScriptRoot)\MaterialDesignColors.dll"
Import-Module "$($PSScriptRoot)\MaterialDesignThemes.wpf.dll"

$addedType = Add-Type -Language CSharp @'
using System.ComponentModel;
using System.Collections.Generic;

namespace TestNamespace
{
    public class PeopleListClass : INotifyPropertyChanged
    {
        private List<object> peopleList;
        public List<object> PeopleList
        {
            get { return peopleList; }
            set
            {
                peopleList = value;
                NotifyPropertyChanged("PeopleList");
            }
        }

        public PeopleListClass()
        {
            peopleList = new List<object>();
        }

        public event PropertyChangedEventHandler PropertyChanged;
        private void NotifyPropertyChanged(string property)
        {
            if(PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(property));
            }
        }
    }
}
'@ -PassThru

# https://www.reddit.com/r/PowerShell/comments/9sd0ex/wpf_xaml_with_c_code_behind/e8puddz/ - https://stackoverflow.com/a/52024106
$assembly = $addedType.Assembly.Fullname.Split(",",2)[0]

# Create thread-safe synchronized Hashtable, accessible from all threads/runspaces
$syncHash = [hashtable]::Synchronized(@{})

# XAML of the application
[xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:materialDesign="http://materialdesigninxaml.net/winfx/xaml/themes"
        xmlns:sys="clr-namespace:System;assembly=mscorlib"
        xmlns:local="clr-namespace:TestNamespace.PeopleListClass;assembly=$($assembly)"
        Title="Get-SwedishNamesXAML"
        SizeToContent="WidthAndHeight"
        ResizeMode="NoResize"

        TextElement.Foreground="{DynamicResource MaterialDesignBody}"
        TextElement.FontWeight="Regular"
        TextElement.FontSize="13"
        TextOptions.TextFormattingMode="Ideal" 
        TextOptions.TextRenderingMode="Auto"        
        Background="{DynamicResource MaterialDesignPaper}"
        FontFamily="{DynamicResource MaterialDesignFont}">

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

    <Grid Width="400">
        <Grid.RowDefinitions>
            <RowDefinition Height="400"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <ListView Name="TestListView">
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="First Name" DisplayMemberBinding="{Binding FirstName}"/>
                    <GridViewColumn Header="Last Name" DisplayMemberBinding="{Binding Surname}"/>
                    <GridViewColumn Header="Gender" DisplayMemberBinding="{Binding Gender}"/>
                </GridView>
            </ListView.View>
        </ListView>
        <Button Content="Get-SwedishNames" Name="PopulateButton" Grid.Row="1" Width="200" Height="60" VerticalAlignment="Top" Margin="8"/>
    </Grid>
</Window>
"@

# Create reader to parse XML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
# Create window from reader content
$syncHash.Window = [Windows.Markup.XamlReader]::Load($reader)

# Creates/sets variables from the objects in the XAML
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object { $syncHash.Add($_.Name,$syncHash.Window.FindName($_.Name)) }

$TestCollection = New-Object TestNamespace.PeopleListClass
$Binding = New-Object System.Windows.Data.Binding
$Binding.Path = "PeopleList"
$Binding.Source = $TestCollection
[void][System.Windows.Data.BindingOperations]::SetBinding($syncHash.TestListView,[System.Windows.Controls.ListView]::ItemsSourceProperty, $Binding)

# add function to get names when button is clicked
$syncHash.PopulateButton.Add_Click{
    $result = Invoke-WebRequest -Uri http://api.namnapi.se/v2/names.json?limit=30 -ContentType "application/json" | ConvertFrom-Json

    $TestCollection.PeopleList.Clear()

    # Pretend long operation is happening
    #Start-Sleep 10

    foreach($item in $result.names)
    {
        [void]$TestCollection.PeopleList.Add($item)
    }
}

[void]$syncHash.Window.Dispatcher.InvokeAsync{$syncHash.Window.ShowDialog()}.Wait()