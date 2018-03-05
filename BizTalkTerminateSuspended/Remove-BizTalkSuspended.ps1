[cmdLetBinding(DefaultParameterSetName='List')]
param (
    [Parameter(HelpMessage="Enable/disable saving messages associated with suspended instances (disabling is not recommended for Production environments)")]
    [string]$SaveMessages='false',
    [Parameter(HelpMessage="Path to the directory where suspended messages and metadata will be saved)")]
    [string]$Destination
)
#$Dest = Join-Path $HOME ('bts_msgs_{0:yyyyMMdd}' -f (Get-Date))

# ServiceClass https://msdn.microsoft.com/en-us/library/ee268202(v=bts.10).aspx
#  1 Orchestration
#  2 Tracking
#  4 Messaging
#  8 MSMQT
# 16 Other
# 32 Isolated adapter
# 64 Routing failure report

# ServiceStatus https://msdn.microsoft.com/en-US/library/ee268242(v=bts.10).aspx
#  1 Ready to run
#  2 Active
#  4 Suspended (resumable)
#  8 Dehydrated
# 16 Completed with discarded messages
# 32 Suspended (not resumable)
# 64 In breakpoint
$ServiceInstances = Get-WmiObject MSBTS_ServiceInstance -Namespace 'root\MicrosoftBizTalkServer' -Filter '(ServiceClass=1 or ServiceClass=4 or ServiceClass=64) and (ServiceStatus = 4 or ServiceStatus = 32)'
if ($ServiceInstances) {
    if ($([bool]::Parse($SaveMessages))) {
        if ([string]::IsNullOrWhiteSpace($Destination)) {
            $Destination = Join-Path $env:Temp 'bts_msgs_{0:yyyyMMdd}'
        }
        $Destination = $Destination -f (Get-Date)
        if (!(Test-Path -Path $Destination)) {
            New-Item -Path $Destination -ItemType Directory | Out-Null
        }
        Write-Host ("Suspended message destination: {0}" -f $Destination)
        $ServiceInstances | ForEach-Object {
            try {
                $InstanceId = $_.InstanceId
                $Messages = Get-WmiObject MSBTS_MessageInstance -Namespace 'root\MicrosoftBizTalkServer' -Filter ("ServiceInstanceID = '{0}'" -f $InstanceID)
                [void]$Messages.SaveToFile($Destination)
                Write-Host ("Save messages [{0}]" -f $InstanceId)
            } catch {
                Write-Host ("##vso[task.logissue type=warning;] Save messages [{0}] FAILED: {1}" -f $InstanceId,$_.Exception.Message)
            }
        }
    }

    # AssociatedInstances include Routing Failure Reports which have no messages to save
    $AssociatedInstances = Get-WmiObject MSBTS_ServiceInstance -Namespace 'root\MicrosoftBizTalkServer' -Filter 'ServiceClass=1 or ServiceClass=4 or ServiceClass=64'
    $ServiceInstances,$AssociatedInstances | ForEach-Object {
        try {
            $InstanceId = $_.InstanceId
            [void]$_.Terminate()
            Write-Host ("Instance termination [{0}]" -f $InstanceId,$_.Exception.Message)
        } catch {
            Write-Host ("##vso[task.logissue type=warning;] Instance termination [{0}] FAILED: {1}" -f $InstanceId,$_.Exception.Message)
        }
    }
} else {
    Write-Host "##vso[task.logissue type=warning;] No suspended instances found."
}