# Include assembly PresentationFramework to be able to create WPF app
Add-Type -AssemblyName PresentationFramework

Import-Module "$($PSScriptRoot)\MaterialDesignColors.dll"
Import-Module "$($PSScriptRoot)\MaterialDesignThemes.wpf.dll"

# Warning: it's easy to experience "runspace creep" with this solution
# it's harder to write manageable, readable code the more threads are created

# Create thread-safe synchronized Hashtable, accessible from all threads/runspaces
$syncHash = [hashtable]::Synchronized(@{})

# create new runspace
$windowRunspace = [RunspaceFactory]::CreateRunspace()
# STA means single-thread apartment and is a mode for COM object thread safety. STA mode is needed for WPF - https://stackoverflow.com/a/485109
$windowRunspace.ApartmentState = "STA"
$windowRunspace.Open()
# make sure that our hashtable is a shared variable accessible between all threads
$windowRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)

# create powershell scriptblock to run in runspace
$psCmd = [PowerShell]::Create().AddScript({    
    # XAML of the application
    [xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:materialDesign="http://materialdesigninxaml.net/winfx/xaml/themes"
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
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    # add Window to the synchronized hashtable to make it accessible
    $syncHash.Window=[Windows.Markup.XamlReader]::Load($reader)
    
    # Adds objects found as nodes in XAML to the synchronized hashtable
    $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object { $syncHash.Add($_.Name,$syncHash.Window.FindName($_.Name)) }
    
    $clickRunspace = [RunspaceFactory]::CreateRunspace()
    $clickRunspace.Open()
    $clickRunspace.SessionStateProxy.SetVariable("syncHash", $syncHash)
    
    $clickCmd = [PowerShell]::Create().AddScript({
        $result = Invoke-WebRequest -Uri http://api.namnapi.se/v2/names.json?limit=30 -ContentType "application/json" | ConvertFrom-Json
    
        # Pretend long operation is happening
        Start-Sleep 10

        $syncHash.TestListView.Dispatcher.Invoke([Action]{
            $syncHash.TestListView.Items.Clear()
            
            foreach($item in $result.names)
            {
                [void]$syncHash.TestListView.Items.Add($item)
            }
        })
    })

    $clickCmd.Runspace = $clickRunspace

    # add function to get names when button is clicked
    # The curly bracket needs to be immediately after the event with no whitespace or line break
    $syncHash.PopulateButton.Add_Click{
        [void]$clickCmd.BeginInvoke()
    }
    
    # Show the window
    [void]$syncHash.Window.ShowDialog()
    
    # after the window closes we want to be able to see if anything went wrong from a thread with logic
    $syncHash.Error = $Error
})

# set our PowerShell session's runspace to our previously created new runspace
$psCmd.Runspace = $windowRunspace

# use begininvoke to start the command asynchronously
# to get the result from the command we would first save the return value from $psCmd.BeginInvoke() and then later call $psCmd.EndInvoke($returnValueFromBeginInvoke) to await the result
# example: $asyncObject = $psCmd.BeginInvoke()
# ... run other code ...
# $data = $psCmd.EndInvoke($asyncObject) - this will block the thread until the command is finished
[void]$psCmd.BeginInvoke()