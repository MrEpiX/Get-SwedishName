# Include assembly PresentationFramework to be able to create WPF app
Add-Type -AssemblyName PresentationFramework

# Create Window
$window = New-Object System.Windows.Window
$window.Title = "Get-SwedishNamesCode"
$window.SizeToContent = [System.Windows.SizeToContent]::WidthAndHeight
#$window.ResizeMode = [System.Windows.ResizeMode]::NoResize

# Create Grid
$grid = New-Object System.Windows.Controls.Grid
$grid.Width = 400

# Create converter for GridLength
$gridLengthConverter = New-Object System.Windows.GridLengthConverter
# Create GridRows and add to Grid
$gridRow1 = New-Object System.Windows.Controls.RowDefinition
$gridRow1.Height = [System.Windows.GridLength]$gridLengthConverter.ConvertFrom(400)
$gridRow2 = New-Object System.Windows.Controls.RowDefinition
$gridRow2.Height = [System.Windows.GridLength]$gridLengthConverter.ConvertFrom("*")
$grid.RowDefinitions.Add($gridRow1)
$grid.RowDefinitions.Add($gridRow2)

# Create ListView and GridView (to get column headers in ListView)
$listView = New-Object System.Windows.Controls.ListView
$gridView = New-Object System.Windows.Controls.GridView
# Create GridViewColumns for property binding
$gridViewColumn1 = New-Object System.Windows.Controls.GridViewColumn
$gridViewColumn1.Header = "First Name"
# Create binding and bind to "FirstName" property of the object stored in ListView later
$binding1 = New-Object System.Windows.Data.Binding
$binding1.Path = "FirstName"
$gridViewColumn1.DisplayMemberBinding = $binding1
$gridViewColumn2 = New-Object System.Windows.Controls.GridViewColumn
$gridViewColumn2.Header = "Last Name"
$binding2 = New-Object System.Windows.Data.Binding
$binding2.Path = "SurName"
$gridViewColumn2.DisplayMemberBinding = $binding2
$gridViewColumn3 = New-Object System.Windows.Controls.GridViewColumn
$gridViewColumn3.Header = "Gender"
$binding3 = New-Object System.Windows.Data.Binding
$binding3.Path = "Gender"
$gridViewColumn3.DisplayMemberBinding = $binding3
# Add GridViewColumns to GridView
$gridView.Columns.Add($gridViewColumn1)
$gridView.Columns.Add($gridViewColumn2)
$gridView.Columns.Add($gridViewColumn3)
# Set ListView's View to GridView
$listView.View = $gridView
# Add ListView to Grid
$grid.AddChild($listView)

# Create Button and set properties
$button = New-Object System.Windows.Controls.Button
$button.Content = "Get-SwedishNames"
$button.Name = "PopulateButton"
$button.Width = 200
$button.Height = 60
$button.Margin = 8
$button.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
# Set Grid row property of Button through static Grid method
[System.Windows.Controls.Grid]::SetRow($button,1)
# Add Button to grid
$grid.AddChild($button)

# add function to get names when button is clicked
$button.Add_Click{
    $result = Invoke-WebRequest -Uri http://api.namnapi.se/v2/names.json?limit=30 -ContentType "application/json" | ConvertFrom-Json

    $listView.Items.Clear()

    # Pretend long operation is happening
    Start-Sleep 10

    foreach($item in $result.names)
    {
        [void]$listView.Items.Add($item)
    }
}

$window.AddChild($grid)

[void]$window.ShowDialog()