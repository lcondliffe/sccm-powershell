<#
.Synopsis
   Remotely forces an assigned SCCM application to install/uninstall on a client.
.EXAMPLE
   Start-SCCMAppInstallation -Computername 4439C492DB00 -AppName "Mudbox 2017"
#>
Function Start-SCCMAppInstallation
{
    [CmdletBinding()]
Param
(
 [Parameter(Mandatory=$True,
            ValueFromPipelineByPropertyName=$true)]
$Computername,

[Parameter(Mandatory=$True)]
$AppName,

[ValidateSet("Install","Uninstall")]
 [String] $Method="Install"
)
#Set error action, so that failure to run CIM commands results in a terminating error upon failure.
$ErrorActionPreference = "Stop"

Try{
   $Application = (Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" -ComputerName $Computername | Where-Object {$_.Name -like $AppName})
}
Catch{
   Write-Warning "Failed to start app installation on $Computername"
}

$Args = @{EnforcePreference = [UINT32] 0
Id = "$($Application.id)"
IsMachineTarget = $Application.IsMachineTarget
IsRebootIfNeeded = $False
Priority = 'High'
Revision = "$($Application.Revision)" }

   Try{
      Invoke-CimMethod -Namespace "root\ccm\clientSDK" -ClassName CCM_Application -ComputerName $Computername -MethodName $Method -Arguments $Args
   }
   Catch{
      Write-Warning "Failed to start app installation on $Computername"
   }

   $ErrorActionPreference = "Continue"
}
