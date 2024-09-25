<#
ssmon.ps1
Monitor Windows Storage Spaces pools and drives.
Send notification via ntfy.sh if problem is detected.
Intended to run as a Scheduled Task at set intervals.

Jarom West
j@jaromwest.com
09/24/2024
#>

# Custom command to run when unhealthy drives are detected
$customCommand = {
    Write-Host "Sending ntfy.sh alert that potential problems are detected..." -ForegroundColor Red
    $uri = "https://ntfy.sh/boxjaromwestcom"
    $body = "WARNING: Possible problem with Storage Pool on server."
    Invoke-WebRequest -Method Post -Uri $uri -Body $body
    Write-Host "ntfy.sh notification sent!" -ForegroundColor Yellow
}

# Function to check and display Physical Disk status
function Check-PhysicalDisks {
    Write-Host "Checking Physical Disks..." -ForegroundColor Cyan
    $physicalDisks = Get-PhysicalDisk | Select-Object DeviceID, FriendlyName, OperationalStatus, HealthStatus
    $unhealthyDisks = @()

    if ($physicalDisks) {
        $physicalDisks | ForEach-Object {
            Write-Host "Disk: $($_.FriendlyName)"
            Write-Host "  Device ID: $($_.DeviceID)"
            Write-Host "  Operational Status: $($_.OperationalStatus)"
            Write-Host "  Health Status: $($_.HealthStatus)"
            Write-Host ""

            # Check if the disk is not healthy
            if ($_.HealthStatus -ne "Healthy") {
                $unhealthyDisks += $_
            }
        }

        if ($unhealthyDisks.Count -gt 0) {
            Write-Host "`nUnhealthy Physical Disks detected!" -ForegroundColor Red
            # Execute custom command
            &$customCommand
        }
    } else {
        Write-Host "No physical disks found." -ForegroundColor Yellow
    }
}

# Function to check and display Storage Pools status
function Check-StoragePools {
    Write-Host "Checking Storage Pools..." -ForegroundColor Cyan
    $storagePools = Get-StoragePool | Select-Object FriendlyName, HealthStatus, OperationalStatus
    $unhealthyPools = @()

    if ($storagePools) {
        $storagePools | ForEach-Object {
            Write-Host "Storage Pool: $($_.FriendlyName)"
            Write-Host "  Operational Status: $($_.OperationalStatus)"
            Write-Host "  Health Status: $($_.HealthStatus)"
            Write-Host ""

            # Check if the Storage Pool is not healthy
            if ($_.HealthStatus -ne "Healthy") {
                $unhealthyPools += $_
            }
        }

        if ($unhealthyPools.Count -gt 0) {
            Write-Host "`nUnhealthy Storage Pools detected!" -ForegroundColor Red
            # Execute custom command
            &$customCommand
        }
    } else {
        Write-Host "No storage pools found." -ForegroundColor Yellow
    }
}

# Function to check and display Virtual Disks status
function Check-VirtualDisks {
    Write-Host "Checking Virtual Disks..." -ForegroundColor Cyan
    $virtualDisks = Get-VirtualDisk | Select-Object FriendlyName, HealthStatus, OperationalStatus, ResiliencySettingName
    $unhealthyVDisks = @()

    if ($virtualDisks) {
        $virtualDisks | ForEach-Object {
            Write-Host "Virtual Disk: $($_.FriendlyName)"
            Write-Host "  Operational Status: $($_.OperationalStatus)"
            Write-Host "  Health Status: $($_.HealthStatus)"
            Write-Host "  Resiliency: $($_.ResiliencySettingName)"
            Write-Host ""

            # Check if the Virtual Disk is not healthy
            if ($_.HealthStatus -ne "Healthy") {
                $unhealthyVDisks += $_
            }
        }

        if ($unhealthyVDisks.Count -gt 0) {
            Write-Host "`nUnhealthy Virtual Disks detected!" -ForegroundColor Red
            # Execute custom command
            &$customCommand
        }
    } else {
        Write-Host "No virtual disks found." -ForegroundColor Yellow
    }
}

# Main script execution
Write-Host "Checking Windows Storage Spaces Status..." -ForegroundColor Green

# Checking Physical Disks
Check-PhysicalDisks

# Checking Storage Pools
Check-StoragePools

# Checking Virtual Disks
Check-VirtualDisks

Write-Host "Status Check Complete." -ForegroundColor Green