# Include assembly PresentationFramework to be able to create WPF app
Add-Type -AssemblyName PresentationFramework

# XAML of the application
[xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Get-SwedishNamesXAML"
        SizeToContent="WidthAndHeight"
        ResizeMode="NoResize">

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
$window = [Windows.Markup.XamlReader]::Load($reader)

# Creates/sets variables from the objects in the XAML
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $window.FindName($_.Name) }

# add function to get names when button is clicked
$PopulateButton.Add_Click{
    $result = Invoke-WebRequest -Uri http://api.namnapi.se/v2/names.json?limit=30 -ContentType "application/json" | ConvertFrom-Json

    $TestListView.Items.Clear()

    # Pretend long operation is happening
    Start-Sleep 10

    foreach($item in $result.names)
    {
        [void]$TestListView.Items.Add($item)
    }
}

[void]$window.ShowDialog()