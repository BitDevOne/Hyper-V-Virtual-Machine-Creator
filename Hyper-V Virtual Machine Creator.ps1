# Load necessary WPF components
Add-Type -AssemblyName PresentationFramework

# Load the Posh-SSH module
if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
    Install-Module -Name Posh-SSH -Force -Scope CurrentUser
}
Import-Module -Name Posh-SSH

# XAML definition with added "Configuration" tab and updated controls
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Hyper-V Virtual Machine Creator" Height="900" Width="1000">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="350"/>
        </Grid.ColumnDefinitions>
        <TabControl x:Name="MainTabControl" Grid.Column="0" HorizontalAlignment="Stretch" VerticalAlignment="Stretch">
            <TabItem Header="Windows">
                <Grid>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="10">
                            <!-- Existing fields -->
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="VM Name:" Margin="0,0,0,5" HorizontalAlignment="Center"/>
                                <TextBox x:Name="WindowsVmName" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Memory (MB):" Margin="0,0,0,5"/>
                                <TextBox x:Name="WindowsMemory" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Switch:" Margin="0,0,0,5"/>
                                <ComboBox x:Name="WindowsSwitch" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Generation:" Margin="0,0,0,5"/>
                                <ComboBox x:Name="WindowsGeneration" Width="200">
                                    <ComboBoxItem Content="1"/>
                                    <ComboBoxItem Content="2"/>
                                </ComboBox>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Disk Size (GB):" Margin="0,0,0,5"/>
                                <TextBox x:Name="WindowsDiskSize" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="VLAN ID:" Margin="0,0,0,5"/>
                                <TextBox x:Name="WindowsVlanId" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Number of CPUs:" Margin="0,0,0,5"/>
                                <ComboBox x:Name="WindowsCpuCount" Width="200"/>
                            </StackPanel>
                            <!-- ISO Path with ComboBox -->
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="ISO Path:" Margin="0,0,0,5"/>
                                <StackPanel Orientation="Horizontal">
                                    <TextBox x:Name="WindowsIsoPath" Width="200" Visibility="Visible"/>
                                    <ComboBox x:Name="WindowsIsoComboBox" Width="200" Visibility="Collapsed"/>
                                    <Button x:Name="BrowseWindowsIso" Content="Browse" Width="75" Margin="5,0,0,0" Visibility="Visible"/>
                                </StackPanel>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="VM Storage Path:" Margin="0,0,0,5"/>
                                <StackPanel Orientation="Horizontal">
                                    <TextBox x:Name="WindowsVmPath" Width="200"/>
                                    <Button x:Name="BrowseWindowsVmPath" Content="Browse" Width="75" Margin="5,0,0,0"/>
                                </StackPanel>
                            </StackPanel>
                            <CheckBox x:Name="WindowsSecureBoot" Content="Disable Secure Boot" IsChecked="True" Margin="0,10,0,10"/>
                            <!-- Additional Disks Section -->
                            <TextBlock Text="Additional Disks:" FontWeight="Bold" Margin="0,0,0,5"/>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Disk Name:" Margin="0,0,0,5"/>
                                <TextBox x:Name="WindowsAdditionalDiskName" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Disk Size (GB):" Margin="0,0,0,5"/>
                                <StackPanel Orientation="Horizontal">
                                    <TextBox x:Name="WindowsAdditionalDiskSize" Width="100"/>
                                    <CheckBox x:Name="WindowsAdditionalDiskDynamic" Content="Dynamic" IsChecked="True" Margin="5,0,0,0"/>
                                </StackPanel>
                            </StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,10,0,10">
                                <Button x:Name="AddWindowsDiskButton" Content="Add Disk" Width="75"/>
                                <Button x:Name="RemoveWindowsDiskButton" Content="Remove Selected Disk" Width="150" Margin="5,0,0,0"/>
                            </StackPanel>
                            <ListBox x:Name="WindowsAdditionalDisks" Width="300" Height="100" Margin="0,0,0,10"/>
                            
                            <!-- Provisioning Button -->
                            <Button x:Name="WindowsProvisioningButton" Content="Provisioning" Width="100" Margin="0,10,0,10"/>

                            <!-- Create VM Button -->
                            <Button x:Name="CreateWindowsVmButton" Content="Create Windows VM" Width="150" Margin="0,10,0,0"/>
                        </StackPanel>
                    </ScrollViewer>
                </Grid>
            </TabItem>
            <TabItem Header="Linux">
                <Grid>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="10">
                            <!-- Existing fields -->
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="VM Name:" Margin="0,0,0,5"/>
                                <TextBox x:Name="LinuxVmName" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Memory (MB):" Margin="0,0,0,5"/>
                                <TextBox x:Name="LinuxMemory" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Switch:" Margin="0,0,0,5"/>
                                <ComboBox x:Name="LinuxSwitch" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Generation:" Margin="0,0,0,5"/>
                                <ComboBox x:Name="LinuxGeneration" Width="200">
                                    <ComboBoxItem Content="1"/>
                                    <ComboBoxItem Content="2"/>
                                </ComboBox>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Disk Size (GB):" Margin="0,0,0,5"/>
                                <TextBox x:Name="LinuxDiskSize" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="VLAN ID:" Margin="0,0,0,5"/>
                                <TextBox x:Name="LinuxVlanId" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Number of CPUs:" Margin="0,0,0,5"/>
                                <ComboBox x:Name="LinuxCpuCount" Width="200"/>
                            </StackPanel>
                            <!-- ISO Path with ComboBox -->
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="ISO Path:" Margin="0,0,0,5"/>
                                <StackPanel Orientation="Horizontal">
                                    <TextBox x:Name="LinuxIsoPath" Width="200" Visibility="Visible"/>
                                    <ComboBox x:Name="LinuxIsoComboBox" Width="200" Visibility="Collapsed"/>
                                    <Button x:Name="BrowseLinuxIso" Content="Browse" Width="75" Margin="5,0,0,0" Visibility="Visible"/>
                                </StackPanel>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="VM Storage Path:" Margin="0,0,0,5"/>
                                <StackPanel Orientation="Horizontal">
                                    <TextBox x:Name="LinuxVmPath" Width="200"/>
                                    <Button x:Name="BrowseLinuxVmPath" Content="Browse" Width="75" Margin="5,0,0,0"/>
                                </StackPanel>
                            </StackPanel>
                            <CheckBox x:Name="LinuxSecureBoot" Content="Disable Secure Boot" IsChecked="True" Margin="0,10,0,10"/>
                            <!-- Additional Disks Section -->
                            <TextBlock Text="Additional Disks:" FontWeight="Bold" Margin="0,0,0,5"/>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Disk Name:" Margin="0,0,0,5"/>
                                <TextBox x:Name="LinuxAdditionalDiskName" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="Disk Size (GB):" Margin="0,0,0,5"/>
                                <StackPanel Orientation="Horizontal">
                                    <TextBox x:Name="LinuxAdditionalDiskSize" Width="100"/>
                                    <CheckBox x:Name="LinuxAdditionalDiskDynamic" Content="Dynamic" IsChecked="True" Margin="5,0,0,0"/>
                                </StackPanel>
                            </StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,10,0,10">
                                <Button x:Name="AddLinuxDiskButton" Content="Add Disk" Width="75"/>
                                <Button x:Name="RemoveLinuxDiskButton" Content="Remove Selected Disk" Width="150" Margin="5,0,0,0"/>
                            </StackPanel>
                            <ListBox x:Name="LinuxAdditionalDisks" Width="300" Height="100" Margin="0,0,0,10"/>
                            
                            <!-- Provisioning Button -->
                            <Button x:Name="LinuxProvisioningButton" Content="Provisioning" Width="100" Margin="0,10,0,10"/>

                            <!-- Create VM Button -->
                            <Button x:Name="CreateLinuxVmButton" Content="Create Linux VM" Width="150" Margin="0,10,0,0"/>
                        </StackPanel>
                    </ScrollViewer>
                </Grid>
            </TabItem>
            <TabItem Header="Configuration">
                <Grid>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="10">
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="SFTP Server Address:" Margin="0,0,0,5"/>
                                <TextBox x:Name="SftpServerAddress" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="SFTP Username:" Margin="0,0,0,5"/>
                                <TextBox x:Name="SftpUsername" Width="200"/>
                            </StackPanel>
                            <StackPanel Margin="0,0,0,10">
                                <TextBlock Text="SFTP Password:" Margin="0,0,0,5"/>
                                <PasswordBox x:Name="SftpPassword" Width="200"/>
                            </StackPanel>
                            <Button x:Name="SaveConfigurationButton" Content="Save Configuration" Width="150" Margin="0,10,0,0"/>
                        </StackPanel>
                    </ScrollViewer>
                </Grid>
            </TabItem>
        </TabControl>
        <!-- Right Side Grid -->
        <Grid Grid.Column="1">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/> <!-- Provisioning Fields -->
                <RowDefinition Height="*"/>    <!-- Output Console -->
            </Grid.RowDefinitions>

            <!-- Provisioning Fields Panel -->
            <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto">
                <StackPanel x:Name="ProvisioningFieldsPanel" Visibility="Collapsed" Margin="10">
                    <!-- Provisioning Fields will be dynamically added here -->
                    <!-- Cancel Button -->
                    <Button x:Name="CancelProvisioningButton" Content="Cancel" Width="75" Margin="0,0,0,10"/>
                </StackPanel>
            </ScrollViewer>

            <!-- Output Console -->
            <TextBox x:Name="OutputConsole" Grid.Row="1" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap" AcceptsReturn="True" Margin="10"/>
        </Grid>
    </Grid>
</Window>
"@

# Load GUI from XML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Function to sanitize filenames
function Get-SafeFilename {
    param(
        [string]$filename
    )
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    $safeFilename = [string]::Join('_', $filename.Split($invalidChars))
    return $safeFilename
}

# Function to append text to the OutputConsole
function Write-OutputConsole {
    param(
        [string]$message
    )
    $outputConsole.AppendText("$message`n")
    $outputConsole.ScrollToEnd()
}

# Function to clear the OutputConsole
function Clear-OutputConsole {
    $outputConsole.Clear()
}

# Initialize flags to track if the disk name fields have been modified by the user
$windowsDiskNameModified = $false
$linuxDiskNameModified = $false

# Initialize hashtable to store provisioning controls
$ProvisioningControls = @{}

# Retrieve GUI elements - Windows
$windowsVmName = $window.FindName("WindowsVmName")
$windowsMemory = $window.FindName("WindowsMemory")
$windowsSwitch = $window.FindName("WindowsSwitch")
$windowsGeneration = $window.FindName("WindowsGeneration")
$windowsDiskSize = $window.FindName("WindowsDiskSize")
$windowsVlanId = $window.FindName("WindowsVlanId")
$windowsCpuCount = $window.FindName("WindowsCpuCount")
$windowsIsoPath = $window.FindName("WindowsIsoPath")
$windowsIsoComboBox = $window.FindName("WindowsIsoComboBox")
$browseWindowsIso = $window.FindName("BrowseWindowsIso")
$windowsVmPath = $window.FindName("WindowsVmPath")
$browseWindowsVmPath = $window.FindName("BrowseWindowsVmPath")
$windowsSecureBoot = $window.FindName("WindowsSecureBoot")
$windowsAdditionalDiskName = $window.FindName("WindowsAdditionalDiskName")
$windowsAdditionalDiskSize = $window.FindName("WindowsAdditionalDiskSize")
$windowsAdditionalDiskDynamic = $window.FindName("WindowsAdditionalDiskDynamic")
$addWindowsDiskButton = $window.FindName("AddWindowsDiskButton")
$removeWindowsDiskButton = $window.FindName("RemoveWindowsDiskButton")
$windowsAdditionalDisks = $window.FindName("WindowsAdditionalDisks")
$createWindowsVmButton = $window.FindName("CreateWindowsVmButton")
$windowsProvisioningButton = $window.FindName("WindowsProvisioningButton")

# Retrieve GUI elements - Linux
$linuxVmName = $window.FindName("LinuxVmName")
$linuxMemory = $window.FindName("LinuxMemory")
$linuxSwitch = $window.FindName("LinuxSwitch")
$linuxGeneration = $window.FindName("LinuxGeneration")
$linuxDiskSize = $window.FindName("LinuxDiskSize")
$linuxVlanId = $window.FindName("LinuxVlanId")
$linuxCpuCount = $window.FindName("LinuxCpuCount")
$linuxIsoPath = $window.FindName("LinuxIsoPath")
$linuxIsoComboBox = $window.FindName("LinuxIsoComboBox")
$browseLinuxIso = $window.FindName("BrowseLinuxIso")
$linuxVmPath = $window.FindName("LinuxVmPath")
$browseLinuxVmPath = $window.FindName("BrowseLinuxVmPath")
$linuxSecureBoot = $window.FindName("LinuxSecureBoot")
$linuxAdditionalDiskName = $window.FindName("LinuxAdditionalDiskName")
$linuxAdditionalDiskSize = $window.FindName("LinuxAdditionalDiskSize")
$linuxAdditionalDiskDynamic = $window.FindName("LinuxAdditionalDiskDynamic")
$addLinuxDiskButton = $window.FindName("AddLinuxDiskButton")
$removeLinuxDiskButton = $window.FindName("RemoveLinuxDiskButton")
$linuxAdditionalDisks = $window.FindName("LinuxAdditionalDisks")
$createLinuxVmButton = $window.FindName("CreateLinuxVmButton")
$linuxProvisioningButton = $window.FindName("LinuxProvisioningButton")

# Retrieve GUI elements - Configuration
$sftpServerAddress = $window.FindName("SftpServerAddress")
$sftpUsername = $window.FindName("SftpUsername")
$sftpPassword = $window.FindName("SftpPassword")
$saveConfigurationButton = $window.FindName("SaveConfigurationButton")

# Retrieve the OutputConsole control
$outputConsole = $window.FindName("OutputConsole")

# Retrieve Provisioning Panel and Cancel Button
$provisioningFieldsPanel = $window.FindName("ProvisioningFieldsPanel")
$cancelProvisioningButton = $window.FindName("CancelProvisioningButton")

# Retrieve the TabControl
$tabControl = $window.FindName("MainTabControl")

# Get available switches and add them to ComboBoxes
$switches = Get-VMSwitch | Select-Object -ExpandProperty Name
foreach ($switch in $switches) {
    $windowsSwitch.Items.Add($switch)
    $linuxSwitch.Items.Add($switch)
}

# Populate CPU Count ComboBoxes
$logicalProcessorCount = (Get-WmiObject -Class Win32_Processor | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
for ($i = 1; $i -le $logicalProcessorCount; $i++) {
    $windowsCpuCount.Items.Add($i)
    $linuxCpuCount.Items.Add($i)
}
# Set default selection
$windowsCpuCount.SelectedIndex = 0
$linuxCpuCount.SelectedIndex = 0

# Event handler for when the user modifies the Windows disk name field
$windowsAdditionalDiskName.Add_TextChanged({
    if ($windowsAdditionalDiskName.IsFocused) {
        $windowsDiskNameModified = $true
    }
})

# Event handler for when the user modifies the Linux disk name field
$linuxAdditionalDiskName.Add_TextChanged({
    if ($linuxAdditionalDiskName.IsFocused) {
        $linuxDiskNameModified = $true
    }
})

# Update disk name when VM name changes - Windows
$windowsVmName.Add_TextChanged({
    if (-not $windowsDiskNameModified) {
        $windowsAdditionalDiskName.Text = $windowsVmName.Text
    }
})

# Update disk name when VM name changes - Linux
$linuxVmName.Add_TextChanged({
    if (-not $linuxDiskNameModified) {
        $linuxAdditionalDiskName.Text = $linuxVmName.Text
    }
})

# Handle Browse button for Windows ISO
$browseWindowsIso.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "ISO Files (*.iso)|*.iso|All Files (*.*)|*.*"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $windowsIsoPath.Text = $dialog.FileName
        Write-OutputConsole "Selected Windows ISO: $($dialog.FileName)"
    }
})

# Handle Browse button for Windows VM Path
$browseWindowsVmPath.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $windowsVmPath.Text = $dialog.SelectedPath
        Write-OutputConsole "Selected Windows VM Path: $($dialog.SelectedPath)"
    }
})

# Handle Add Disk button for Windows
$addWindowsDiskButton.Add_Click({
    $diskSize = [int]$windowsAdditionalDiskSize.Text
    $isDynamic = $windowsAdditionalDiskDynamic.IsChecked
    $diskName = $windowsAdditionalDiskName.Text

    if ([string]::IsNullOrWhiteSpace($diskName)) {
        $diskName = $windowsVmName.Text
    }

    if ($diskSize -gt 0) {
        # Optionally ask for disk path
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $result = [System.Windows.Forms.MessageBox]::Show("Do you want to specify a custom disk path?", "Disk Path", [System.Windows.Forms.MessageBoxButtons]::YesNo)
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
            if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $diskPath = $dialog.SelectedPath
            } else {
                # If user cancels, default to VM path
                $diskPath = $windowsVmPath.Text
            }
        } else {
            # Default to VM path
            $diskPath = $windowsVmPath.Text
        }

        $diskType = if ($isDynamic) { "Dynamic" } else { "Fixed" }
        # Update the ListBox item to include disk name
        $windowsAdditionalDisks.Items.Add("Name: $diskName, Path: $diskPath, Size: ${diskSize}GB, Type: $diskType")

        # Clear the Disk Size TextBox
        $windowsAdditionalDiskSize.Text = ""
        Write-OutputConsole "Added disk: Name='$diskName', Path='$diskPath', Size='${diskSize}GB', Type='$diskType'"
    } else {
        Write-OutputConsole "Please provide a valid disk size."
    }
})

# Handle Remove Disk button for Windows
$removeWindowsDiskButton.Add_Click({
    if ($windowsAdditionalDisks.SelectedIndex -ge 0) {
        $selectedDisk = $windowsAdditionalDisks.SelectedItem.ToString()
        $windowsAdditionalDisks.Items.RemoveAt($windowsAdditionalDisks.SelectedIndex)
        Write-OutputConsole "Removed disk: $selectedDisk"
    } else {
        Write-OutputConsole "Please select a disk to remove."
    }
})

# Handle Browse button for Linux ISO
$browseLinuxIso.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "ISO Files (*.iso)|*.iso|All Files (*.*)|*.*"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $linuxIsoPath.Text = $dialog.FileName
        Write-OutputConsole "Selected Linux ISO: $($dialog.FileName)"
    }
})

# Handle Browse button for Linux VM Path
$browseLinuxVmPath.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $linuxVmPath.Text = $dialog.SelectedPath
        Write-OutputConsole "Selected Linux VM Path: $($dialog.SelectedPath)"
    }
})

# Handle Add Disk button for Linux
$addLinuxDiskButton.Add_Click({
    $diskSize = [int]$linuxAdditionalDiskSize.Text
    $isDynamic = $linuxAdditionalDiskDynamic.IsChecked
    $diskName = $linuxAdditionalDiskName.Text

    if ([string]::IsNullOrWhiteSpace($diskName)) {
        $diskName = $linuxVmName.Text
    }

    if ($diskSize -gt 0) {
        # Optionally ask for disk path
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $result = [System.Windows.Forms.MessageBox]::Show("Do you want to specify a custom disk path?", "Disk Path", [System.Windows.Forms.MessageBoxButtons]::YesNo)
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
            if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $diskPath = $dialog.SelectedPath
            } else {
                # If user cancels, default to VM path
                $diskPath = $linuxVmPath.Text
            }
        } else {
            # Default to VM path
            $diskPath = $linuxVmPath.Text
        }

        $diskType = if ($isDynamic) { "Dynamic" } else { "Fixed" }
        # Update the ListBox item to include disk name
        $linuxAdditionalDisks.Items.Add("Name: $diskName, Path: $diskPath, Size: ${diskSize}GB, Type: $diskType")

        # Clear the Disk Size TextBox
        $linuxAdditionalDiskSize.Text = ""
        Write-OutputConsole "Added disk: Name='$diskName', Path='$diskPath', Size='${diskSize}GB', Type='$diskType'"
    } else {
        Write-OutputConsole "Please provide a valid disk size."
    }
})

# Handle Remove Disk button for Linux
$removeLinuxDiskButton.Add_Click({
    if ($linuxAdditionalDisks.SelectedIndex -ge 0) {
        $selectedDisk = $linuxAdditionalDisks.SelectedItem.ToString()
        $linuxAdditionalDisks.Items.RemoveAt($linuxAdditionalDisks.SelectedIndex)
        Write-OutputConsole "Removed disk: $selectedDisk"
    } else {
        Write-OutputConsole "Please select a disk to remove."
    }
})

# Function to check SFTP configuration
function Check-SftpConfiguration {
    $configFilePath = ".\Settings\windows_config.xml"
    Write-Host "Config file path: $configFilePath"
    if (Test-Path $configFilePath) {
        Write-Host "Config file exists."

        # Load XML file
        $xmlDocument = [xml](Get-Content -Path $configFilePath)

        # Get data from XML file
        $SftpServerAddress = $xmlDocument.settings.SftpServerAddress
        $SftpUsername = $xmlDocument.settings.SftpUsername
        $SftpPassword = $xmlDocument.settings.SftpPassword

        if ($SftpServerAddress -and $SftpUsername -and $SftpPassword) {
            Write-Host "All required properties are present."
            return @{
                SftpServerAddress = $SftpServerAddress
                SftpUsername = $SftpUsername
                SftpPassword = $SftpPassword
            }
        } else {
            Write-Host "Required properties are missing."
        }
    } else {
        Write-Host "Config file does not exist."
    }
    return $null
}

# Function to get list of ISO files from SFTP server
function Get-SftpIsoFiles {
    param(
        [string]$sftpServer,
        [string]$username,
        [string]$password
    )
    try {
        # Create new SSH session
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
        $session = New-SFTPSession -ComputerName $sftpServer -Credential $credential -AcceptKey

        # List ISO files in root directory (modify path if needed)
        $files = Get-SFTPChildItem -SessionId $session.SessionId -Path "." | Where-Object { $_.Name -like "*.iso" }

        # Close session
        Remove-SFTPSession -SessionId $session.SessionId

        return $files.Name
    } catch {
        Write-Host "Error retrieving ISO files from SFTP server: $_"
        return @()
    }
}

# Function to download ISO file from SFTP server
function Get-SftpFile {
    param(
        [string]$sftpServer,
        [string]$username,
        [string]$password,
        [string]$remoteFilePath,
        [string]$localFilePath
    )
    try {
        # Create new SSH session
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
        $session = New-SFTPSession -ComputerName $sftpServer -Credential $credential -AcceptKey

        # Download file
        Get-SFTPFile -SessionId $session.SessionId -RemoteFile $remoteFilePath -LocalPath $localFilePath

        # Close session
        Remove-SFTPSession -SessionId $session.SessionId
    } catch {
        Write-Host "Error downloading ISO file from SFTP server: $_"
    }
}

# Function to update ISO selection controls
function UpdateIsoSelectionControls {
    $configData = Check-SftpConfiguration
    if ($configData -ne $null) {
        # SFTP data is available, retrieve ISO files
        Write-Host $configData

        $SftpServerAddress = $configData.SftpServerAddress
        $SftpUsername = $configData.SftpUsername
        $SftpPassword = $configData.SftpPassword

        $isoFiles = Get-SftpIsoFiles -sftpServer $SftpServerAddress -username $SftpUsername -password $SftpPassword
        # Filter $isoFiles to include only valid strings
        $isoFiles = $isoFiles | Where-Object { $_ -is [string] -and $_.EndsWith(".iso") }
        Write-Host $isoFiles

        if ($isoFiles.Count -gt 0) {
            # Windows ISO ComboBox
            $windowsIsoComboBox.Items.Clear()
            foreach ($iso in $isoFiles) {
                $windowsIsoComboBox.Items.Add($iso)
            }
            $windowsIsoComboBox.Visibility = "Visible"
            $windowsIsoPath.Visibility = "Collapsed"
            $browseWindowsIso.Visibility = "Collapsed"

            # Linux ISO ComboBox
            $linuxIsoComboBox.Items.Clear()
            foreach ($iso in $isoFiles) {
                $linuxIsoComboBox.Items.Add($iso)
            }
            $linuxIsoComboBox.Visibility = "Visible"
            $linuxIsoPath.Visibility = "Collapsed"
            $browseLinuxIso.Visibility = "Collapsed"
        } else {
            Write-Host "No ISO files found on SFTP server."
        }
    } else {
        # SFTP data not available, use text boxes and browse buttons
        $windowsIsoComboBox.Visibility = "Collapsed"
        $windowsIsoPath.Visibility = "Visible"
        $browseWindowsIso.Visibility = "Visible"

        $linuxIsoComboBox.Visibility = "Collapsed"
        $linuxIsoPath.Visibility = "Visible"
        $browseLinuxIso.Visibility = "Visible"
    }
}

# Handle Save Configuration button
$saveConfigurationButton.Add_Click({
    # Create new XML document
    $xmlDoc = New-Object System.Xml.XmlDocument

    # Create root element 'settings'
    $settingsElement = $xmlDoc.CreateElement("settings")

    # Create and add 'SftpServerAddress' element
    $serverElement = $xmlDoc.CreateElement("SftpServerAddress")
    $serverElement.InnerText = $sftpServerAddress.Text
    $settingsElement.AppendChild($serverElement)

    # Create and add 'SftpUsername' element
    $usernameElement = $xmlDoc.CreateElement("SftpUsername")
    $usernameElement.InnerText = $sftpUsername.Text
    $settingsElement.AppendChild($usernameElement)

    # Create and add 'SftpPassword' element
    $passwordElement = $xmlDoc.CreateElement("SftpPassword")
    $passwordElement.InnerText = $sftpPassword.Password
    $settingsElement.AppendChild($passwordElement)

    # Add 'settings' element to XML document
    $xmlDoc.AppendChild($settingsElement)

    # Save XML document to file
    $configFilePath = ".\Settings\windows_config.xml"
    $xmlDoc.Save($configFilePath)

    Write-Host "Configuration saved to $configFilePath"
    UpdateIsoSelectionControls
})

# Update ISO selection controls on startup
UpdateIsoSelectionControls

# Add event handler for TabControl selection changed
$tabControl.Add_SelectionChanged({
    param($sender, $e)
    if ($e.OriginalSource -is [System.Windows.Controls.TabControl]) {
        UpdateIsoSelectionControls
    }
})


# Handle Provisioning button - Windows
$windowsProvisioningButton.Add_Click({
    # Clear existing fields in the provisioning panel
    $provisioningFieldsPanel.Children.Clear()
    $ProvisioningControls.Remove("Windows")

    # Add Provisioning Fields to the panel
    Add-ProvisioningFields -osType "Windows"

    $provisioningFieldsPanel.Visibility = "Visible"
    Write-OutputConsole "Provisioning options enabled for Windows VM."
})

# Handle Provisioning button - Linux
$linuxProvisioningButton.Add_Click({
    # Clear existing fields in the provisioning panel
    $provisioningFieldsPanel.Children.Clear()
    $ProvisioningControls.Remove("Linux")

    # Add Provisioning Fields to the panel
    Add-ProvisioningFields -osType "Linux"

    $provisioningFieldsPanel.Visibility = "Visible"
    Write-OutputConsole "Provisioning options enabled for Linux VM."
})

# Handle Cancel Provisioning button
$cancelProvisioningButton.Add_Click({
    $provisioningFieldsPanel.Visibility = "Collapsed"
    $provisioningFieldsPanel.Children.Clear()
    $ProvisioningControls.Clear()
    Write-OutputConsole "Provisioning options canceled."
})

# Function to add provisioning fields dynamically
function Add-ProvisioningFields {
    param (
        [string]$osType
    )

    # Initialize hashtable for this OS type
    $ProvisioningControls[$osType] = @{}

    # Computer Name
    $computerNameStack = New-Object System.Windows.Controls.StackPanel
    $computerNameStack.Margin = "0,0,0,10"
    $computerNameText = New-Object System.Windows.Controls.TextBlock
    $computerNameText.Text = "Computer Name:"
    $computerNameText.Margin = "0,0,0,5"
    $computerNameBox = New-Object System.Windows.Controls.TextBox
    $computerNameBox.Width = 200
    $computerNameStack.Children.Add($computerNameText)
    $computerNameStack.Children.Add($computerNameBox)
    $provisioningFieldsPanel.Children.Add($computerNameStack)
    $ProvisioningControls[$osType]["ComputerName"] = $computerNameBox

    # IP Address
    $ipAddressStack = New-Object System.Windows.Controls.StackPanel
    $ipAddressStack.Margin = "0,0,0,10"
    $ipAddressText = New-Object System.Windows.Controls.TextBlock
    $ipAddressText.Text = "IP Address:"
    $ipAddressText.Margin = "0,0,0,5"
    $ipAddressBox = New-Object System.Windows.Controls.TextBox
    $ipAddressBox.Width = 200
    $ipAddressStack.Children.Add($ipAddressText)
    $ipAddressStack.Children.Add($ipAddressBox)
    $provisioningFieldsPanel.Children.Add($ipAddressStack)
    $ProvisioningControls[$osType]["IPAddress"] = $ipAddressBox

    # Gateway
    $ipGatewayStack = New-Object System.Windows.Controls.StackPanel
    $ipGatewayStack.Margin = "0,0,0,10"
    $ipGatewayText = New-Object System.Windows.Controls.TextBlock
    $ipGatewayText.Text = "Gateway:"
    $ipGatewayText.Margin = "0,0,0,5"
    $ipGatewayBox = New-Object System.Windows.Controls.TextBox
    $ipGatewayBox.Width = 200
    $ipGatewayStack.Children.Add($ipGatewayText)
    $ipGatewayStack.Children.Add($ipGatewayBox)
    $provisioningFieldsPanel.Children.Add($ipGatewayStack)
    $ProvisioningControls[$osType]["IPGateway"] = $ipGatewayBox

    # Mask
    # Subnet Mask
    $ipMaskStack = New-Object System.Windows.Controls.StackPanel
    $ipMaskStack.Margin = "0,0,0,10"
    $ipMaskText = New-Object System.Windows.Controls.TextBlock
    $ipMaskText.Text = "Subnet Mask:"
    $ipMaskText.Margin = "0,0,0,5"
    $ipMaskBox = New-Object System.Windows.Controls.TextBox
    $ipMaskBox.Width = 200
    $ipMaskStack.Children.Add($ipMaskText)
    $ipMaskStack.Children.Add($ipMaskBox)
    $provisioningFieldsPanel.Children.Add($ipMaskStack)
    $ProvisioningControls[$osType]["IPMask"] = $ipMaskBox

    # DNS1 Servers
    $dns1Stack = New-Object System.Windows.Controls.StackPanel
    $dns1Stack.Margin = "0,0,0,10"
    $dns1Text = New-Object System.Windows.Controls.TextBlock
    $dns1Text.Text = "DNS Server 1:"
    $dns1Text.Margin = "0,0,0,5"
    $dns1Box = New-Object System.Windows.Controls.TextBox
    $dns1Box.Width = 200
    $dns1Stack.Children.Add($dns1Text)
    $dns1Stack.Children.Add($dns1Box)
    $provisioningFieldsPanel.Children.Add($dns1Stack)
    $ProvisioningControls[$osType]["DNSServer1"] = $dns1Box

    # DNS2 Servers
    $dns2Stack = New-Object System.Windows.Controls.StackPanel
    $dns2Stack.Margin = "0,0,0,10"
    $dns2Text = New-Object System.Windows.Controls.TextBlock
    $dns2Text.Text = "DNS Server 2:"
    $dns2Text.Margin = "0,0,0,5"
    $dns2Box = New-Object System.Windows.Controls.TextBox
    $dns2Box.Width = 200
    $dns2Stack.Children.Add($dns2Text)
    $dns2Stack.Children.Add($dns2Box)
    $provisioningFieldsPanel.Children.Add($dns2Stack)
    $ProvisioningControls[$osType]["DNSServer2"] = $dns2Box

    # Computer Password
    $passwordStack = New-Object System.Windows.Controls.StackPanel
    $passwordStack.Margin = "0,0,0,10"
    $passwordText = New-Object System.Windows.Controls.TextBlock
    $passwordText.Text = "Computer Password:"
    $passwordText.Margin = "0,0,0,5"
    $passwordBox = New-Object System.Windows.Controls.PasswordBox
    $passwordBox.Width = 200
    $passwordStack.Children.Add($passwordText)
    $passwordStack.Children.Add($passwordBox)
    $provisioningFieldsPanel.Children.Add($passwordStack)
    $ProvisioningControls[$osType]["ComputerPassword"] = $passwordBox

    # Add the Cancel Button at the end if it's not already added
    if (-not $provisioningFieldsPanel.Children.Contains($cancelProvisioningButton)) {
        $provisioningFieldsPanel.Children.Add($cancelProvisioningButton)
    }
}

# Define action for Create Windows VM button
$createWindowsVmButton.Add_Click({
    Clear-OutputConsole
    Write-OutputConsole "Starting creation of Windows VM..."

    $vmName = $windowsVmName.Text
    $memory = [int]$windowsMemory.Text
    $switchName = $windowsSwitch.Text
    $generation = [int]$windowsGeneration.SelectedItem.Content
    $diskSize = [int]$windowsDiskSize.Text
    $vlanId = $windowsVlanId.Text
    $vmPath = $windowsVmPath.Text
    $secureBootDisabled = $windowsSecureBoot.IsChecked
    $cpuCount = [int]$windowsCpuCount.SelectedItem

    # Get ISO Path
    if ($windowsIsoComboBox.Visibility -eq "Visible") {
        $selectedIso = $windowsIsoComboBox.SelectedItem
        if ($selectedIso -ne $null) {
            # Download the ISO file from the SFTP server to a local path
            $configData = Check-SftpConfiguration
            $SftpServerAddress = $configData.SftpServerAddress
            $SftpUsername = $configData.SftpUsername
            $SftpPassword = $configData.SftpPassword
            $localIsoPath = "$vmPath\$selectedIso"
            Write-OutputConsole "Downloading ISO '$selectedIso' from SFTP server..."
            Get-SftpFile -sftpServer $SftpServerAddress -username $SftpUsername -password $SftpPassword -remoteFilePath $selectedIso -localFilePath $localIsoPath
            $isoPath = $localIsoPath
        } else {
            Write-OutputConsole "Please select an ISO file from the dropdown."
            return
        }
    } else {
        $isoPath = $windowsIsoPath.Text
        if (-not (Test-Path $isoPath)) {
            Write-OutputConsole "ISO path is invalid."
            return
        }
    }

    # Check if provisioning fields are visible and for Windows
    $doProvisioning = $provisioningFieldsPanel.Visibility -eq "Visible" -and $ProvisioningControls.ContainsKey("Windows")
    if ($doProvisioning) {
        $controls = $ProvisioningControls["Windows"]
        $computerName = $controls["ComputerName"].Text
        $ipAddress = $controls["IPAddress"].Text
        $dnsServers = $controls["DNSServers"].Text
        $computerPassword = $controls["ComputerPassword"].Password
    }

    if (-not [string]::IsNullOrWhiteSpace($vmName) -and $memory -gt 0 -and -not [string]::IsNullOrWhiteSpace($switchName) -and $diskSize -gt 0 -and (Test-Path $isoPath) -and (Test-Path $vmPath) -and $cpuCount -gt 0) {
        try {
            Write-OutputConsole "Creating VM '$vmName'..."
            New-VM -Name $vmName -MemoryStartupBytes ($memory * 1MB) -Generation $generation -SwitchName $switchName -Path $vmPath -NewVHDPath "$vmPath\$vmName.vhdx" -NewVHDSizeBytes ($diskSize * 1GB) -ErrorAction Stop
            Write-OutputConsole "VM '$vmName' created."

            if ($vlanId -ne "") {
                Set-VMNetworkAdapterVlan -VMName $vmName -Access -VlanId ([int]$vlanId)
                Write-OutputConsole "Set VLAN ID to $vlanId."
            }

            Add-VMDvdDrive -VMName $vmName -Path $isoPath
            Write-OutputConsole "Attached ISO: $isoPath"

            Set-VMProcessor -VMName $vmName -Count $cpuCount
            Write-OutputConsole "Set CPU count to $cpuCount."

            if ($secureBootDisabled -and $generation -eq 2) {
                Set-VMFirmware -VMName $vmName -EnableSecureBoot Off
                Write-OutputConsole "Secure Boot disabled."
            }

            foreach ($disk in $windowsAdditionalDisks.Items) {
                $diskInfo = $disk.ToString() -split ","
                $diskName = ($diskInfo[0] -replace "Name: ", "").Trim()
                $diskPath = ($diskInfo[1] -replace "Path: ", "").Trim()
                $diskSize = [int]($diskInfo[2] -replace "Size: |GB", "").Trim()
                $diskType = ($diskInfo[3] -replace "Type: ", "").Trim()
                $isDynamic = $diskType -eq "Dynamic"

                $diskName = Get-SafeFilename -filename $diskName
                $additionalDiskPath = "$diskPath\$diskName.vhdx"

                Write-OutputConsole "Creating additional disk '$additionalDiskPath'..."
                if ($isDynamic) {
                    New-VHD -Path $additionalDiskPath -SizeBytes ($diskSize * 1GB) -Dynamic
                } else {
                    New-VHD -Path $additionalDiskPath -SizeBytes ($diskSize * 1GB) -Fixed
                }

                Add-VMHardDiskDrive -VMName $vmName -Path $additionalDiskPath
                Write-OutputConsole "Added additional disk: $additionalDiskPath"
            }

            # Handle provisioning if enabled
            if ($doProvisioning) {
                Write-OutputConsole "Configuring provisioning options..."

                # Generate unattend.xml
                $unattendPath = "$vmPath\unattend.xml"

                # Create unattend.xml content
                $unattendContent = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="" versionScope="nonSxS">
            <UserAccounts>
                <AdministratorPassword>
                    <Value>$($computerPassword | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)</Value>
                    <PlainText>false</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <ComputerName>$computerName</ComputerName>
        </component>
    </settings>
</unattend>
"@

                $unattendContent | Out-File -FilePath $unattendPath -Encoding UTF8

                Write-OutputConsole "Created unattend.xml at $unattendPath"

                # Note: Injecting unattend.xml into a VM requires additional steps not covered here.
                # You may need to use PowerShell Direct or mount the VHD to inject the file.
                
            }

            Write-OutputConsole "Windows VM '$vmName' created successfully."
        } catch {
            Write-OutputConsole "Error creating VM: $_"
        }
    } else {
        Write-OutputConsole "Please provide valid inputs for all required fields."
    }
})

# Define action for Create Linux VM button
$createLinuxVmButton.Add_Click({
    Clear-OutputConsole
    Write-OutputConsole "Starting creation of Linux VM..."

    $vmName = $linuxVmName.Text
    $memory = [int]$linuxMemory.Text
    $switchName = $linuxSwitch.Text
    $generation = [int]$linuxGeneration.SelectedItem.Content
    $diskSize = [int]$linuxDiskSize.Text
    $vlanId = $linuxVlanId.Text
    $vmPath = $linuxVmPath.Text
    $secureBootDisabled = $linuxSecureBoot.IsChecked
    $cpuCount = [int]$linuxCpuCount.SelectedItem

    # Get ISO Path
    if ($linuxIsoComboBox.Visibility -eq "Visible") {
        $selectedIso = $linuxIsoComboBox.SelectedItem
        if ($selectedIso -ne $null) {
            # Download the ISO file from the SFTP server to a local path
            $configData = Check-SftpConfiguration
            $localIsoPath = "$vmPath\$selectedIso"
            Write-OutputConsole "Downloading ISO '$selectedIso' from SFTP server..."
            Get-SftpFile -sftpServer $configData.SftpServerAddress -username $configData.SftpUsername -password $configData.SftpPassword -remoteFilePath $selectedIso -localFilePath $localIsoPath
            $isoPath = $localIsoPath
        } else {
            Write-OutputConsole "Please select an ISO file from the dropdown."
            return
        }
    } else {
        $isoPath = $linuxIsoPath.Text
        if (-not (Test-Path $isoPath)) {
            Write-OutputConsole "ISO path is invalid."
            return
        }
    }

    # Check if provisioning fields are visible and for Linux
    $doProvisioning = $provisioningFieldsPanel.Visibility -eq "Visible" -and $ProvisioningControls.ContainsKey("Linux")
    if ($doProvisioning) {
        $controls = $ProvisioningControls["Linux"]
        $computerName = $controls["ComputerName"].Text
        $ipAddress = $controls["IPAddress"].Text
        $dnsServers = $controls["DNSServers"].Text
        $computerPassword = $controls["ComputerPassword"].Password
    }

    if (-not [string]::IsNullOrWhiteSpace($vmName) -and $memory -gt 0 -and -not [string]::IsNullOrWhiteSpace($switchName) -and $diskSize -gt 0 -and (Test-Path $isoPath) -and (Test-Path $vmPath) -and $cpuCount -gt 0) {
        try {
            Write-OutputConsole "Creating VM '$vmName'..."
            New-VM -Name $vmName -MemoryStartupBytes ($memory * 1MB) -Generation $generation -SwitchName $switchName -Path $vmPath -NewVHDPath "$vmPath\$vmName.vhdx" -NewVHDSizeBytes ($diskSize * 1GB) -ErrorAction Stop
            Write-OutputConsole "VM '$vmName' created."

            if ($vlanId -ne "") {
                Set-VMNetworkAdapterVlan -VMName $vmName -Access -VlanId ([int]$vlanId)
                Write-OutputConsole "Set VLAN ID to $vlanId."
            }

            Add-VMDvdDrive -VMName $vmName -Path $isoPath
            Write-OutputConsole "Attached ISO: $isoPath"

            Set-VMProcessor -VMName $vmName -Count $cpuCount
            Write-OutputConsole "Set CPU count to $cpuCount."

            if ($secureBootDisabled -and $generation -eq 2) {
                Set-VMFirmware -VMName $vmName -EnableSecureBoot Off
                Write-OutputConsole "Secure Boot disabled."
            }

            foreach ($disk in $linuxAdditionalDisks.Items) {
                $diskInfo = $disk.ToString() -split ","
                $diskName = ($diskInfo[0] -replace "Name: ", "").Trim()
                $diskPath = ($diskInfo[1] -replace "Path: ", "").Trim()
                $diskSize = [int]($diskInfo[2] -replace "Size: |GB", "").Trim()
                $diskType = ($diskInfo[3] -replace "Type: ", "").Trim()
                $isDynamic = $diskType -eq "Dynamic"

                $diskName = Get-SafeFilename -filename $diskName
                $additionalDiskPath = "$diskPath\$diskName.vhdx"

                Write-OutputConsole "Creating additional disk '$additionalDiskPath'..."
                if ($isDynamic) {
                    New-VHD -Path $additionalDiskPath -SizeBytes ($diskSize * 1GB) -Dynamic
                } else {
                    New-VHD -Path $additionalDiskPath -SizeBytes ($diskSize * 1GB) -Fixed
                }

                Add-VMHardDiskDrive -VMName $vmName -Path $additionalDiskPath
                Write-OutputConsole "Added additional disk: $additionalDiskPath"
            }

            # Handle provisioning if enabled
            if ($doProvisioning) {
                Write-OutputConsole "Configuring provisioning options..."

                # Create cloud-init ISO
                $cloudInitISOPath = "$vmPath\cloud-init.iso"
                $userData = @"
#cloud-config
hostname: $computerName
password: $computerPassword
chpasswd: { expire: False }
ssh_pwauth: True
"@

                if (-not [string]::IsNullOrWhiteSpace($ipAddress)) {
                    $networkConfig = @"
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [$ipAddress/24]
      gateway4: $($ipAddress -replace '\.\d+$', '.1')
      nameservers:
        addresses: [$dnsServers]
"@
                } else {
                    $networkConfig = ""
                }

                # Create the cloud-init ISO
                $tempPath = "$vmPath\cloud-init"
                New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
                $userData | Out-File -FilePath "$tempPath\user-data" -Encoding UTF8
                if ($networkConfig -ne "") {
                    $networkConfig | Out-File -FilePath "$tempPath\network-config" -Encoding UTF8
                }

                # Create ISO using genisoimage (Ensure genisoimage is installed)
                $isoCommand = "genisoimage -output `"$cloudInitISOPath`" -volid cidata -joliet -rock `"$tempPath`""
                Invoke-Expression $isoCommand

                # Attach the cloud-init ISO to the VM
                Add-VMDvdDrive -VMName $vmName -Path $cloudInitISOPath
                Write-OutputConsole "Attached cloud-init ISO: $cloudInitISOPath"
            }

            Write-OutputConsole "Linux VM '$vmName' created successfully."
        } catch {
            Write-OutputConsole "Error creating VM: $_"
        }
    } else {
        Write-OutputConsole "Please provide valid inputs for all required fields."
    }
})

# Display the GUI window
$window.ShowDialog() | Out-Null
