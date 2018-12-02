<#
Import-Module "$($PSScriptRoot)\MaterialDesignColors.dll"
Import-Module "$($PSScriptRoot)\MaterialDesignThemes.wpf.dll"

    <Window.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Dark.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Defaults.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignColors;component/Themes/Recommended/Primary/MaterialDesignColor.Amber.xaml" />
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
Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Get-SwedishNamesXAML"
        SizeToContent="WidthAndHeight">

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

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$window=[Windows.Markup.XamlReader]::Load($reader)

# Create variables from the objects in the XAML
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $window.FindName($_.Name) }

$PopulateButton.Add_Click{
    $result = Invoke-WebRequest -Uri http://api.namnapi.se/v2/names.json?limit=30 -ContentType "application/json" | ConvertFrom-Json

    $TestListView.Items.Clear()

    # Pretend long operation is happening
    #Start-Sleep 10

    foreach($item in $result.names)
    {
        [void]$TestListView.Items.Add($item)
    }
}

[void]$window.ShowDialog()