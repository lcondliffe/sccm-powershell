<#
.Synopsis
   Luke Williams, ORC EPD.
   Retrieves SCCM application deployment status information.
.EXAMPLE
   Get-SCCMAppDeploymentStatus -app_name "revit 2020"
.EXAMPLE
   Get-SCCMAppDeploymentStatus -application "Revit 2020" -Installed
.EXAMPLE
   Get-SCCMAppDeploymentStatus -application "Revit 2020" -NotInstalled -Detail
#>
Function Get-SCCMAppDeploymentStatus{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        $application,

        [Parameter(Mandatory=$True)]
        $sccmsitecode = "TST:",

        [switch] $NotInstalled,

        [switch] $Installed,

        [switch] $Detail
    )

    try{
        import-module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
        cd $sccmsitecode
    }
    catch{
        Write-Warning "You must have the SCCM console installed and be connected to the SCCM site."
    }

    $app = Get-CMApplication -Name $application
    $result = Get-CMApplicationDeploymentStatus -InputObject $app | where {$_.AppStatusType -ne $null} | Get-CMDeploymentStatusDetails
    
    $compliant = $result | where {$_.ComplianceState -eq 1}
    $noncompliant = $result | where {$_.ComplianceState -eq 2}
    $unknown = $result | where {$_.ComplianceState -eq 0}

    if ($NotInstalled -eq $true){
        if ($detail -eq $true){
            return $noncompliant
        }
        else{
            return $noncompliant.MachineName
        }
    }
    elseif ($Installed -eq $true){
        if ($detail -eq $true){
            return $compliant
        }
        else{
            return $compliant.MachineName
        }
    }

    #Summary
    Write-Host "Deployment Summary:"
    Write-Host -ForegroundColor green "Compliant:"
    Write-Output $compliant.count

    Write-Host -ForegroundColor yellow "Non-Compliant:"
    Write-Output $noncompliant.count

    Write-Host -ForegroundColor DarkGray "Unknown:"
    Write-Output $unknown.count
    }