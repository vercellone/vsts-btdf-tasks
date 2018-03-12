[cmdletBinding()]
param(
	[Parameter(Mandatory)]
	[string]$Name,

	[string]$BTDeployMgmtDB=$true
)
. "$PSScriptRoot\Init-BTDFTasks.ps1"

function Test-BTDFApplicationDeployed {
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$Name
    )
    begin {
        #=== Make sure the ExplorerOM assembly is loaded ===#
        [void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")
        #=== Connect the BizTalk Management database ===#
        $Catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
        $MgmtDBServer = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\BizTalk Server\3.0\Administration' | Select-Object -ExpandProperty 'MgmtDBServer'
        $Catalog.ConnectionString = "SERVER=$MgmtDBServer;DATABASE=BizTalkMgmtDb;Integrated Security=SSPI"
    }
    process {
        #=== Loop through applications in the catalog trying to find a name match ===#
        foreach($app in $Name) {
            $Catalog.Applications.Name -contains $app
        }
    }
}
if (Test-BTDFApplicationDeployed -Name $Name) {
    $ApplicationPath = Join-Path $ProgramFiles $Name

    $BTDFProject = Get-ChildItem -Path $ApplicationPath -Filter '*.btdfproj' -Recurse | Select-Object -ExpandProperty FullName -First 1
    $DeployResults = Get-ChildItem -Path $ApplicationPath -Filter 'DeployResults' -Recurse | Select-Object -ExpandProperty FullName -First 1
    if ($null -eq $DeployResults) {
        Write-Host ("##vso[task.logissue type=warning;] BTDF application '{0}' not found." -f $ApplicationPath)
    } else {
        $DeployResults = Join-Path $DeployResults 'DeployResults.txt'

        $BTDFMSBuild = Get-MSBuildPath
        $arguments = [string[]]@(
            "/l:FileLogger,Microsoft.Build.Engine;logfile=`"$DeployResults`""
            "/p:Configuration=Server"
            "/p:DeployBizTalkMgmtDB=$BTDeployMgmtDB"
            '/target:Undeploy'
            """$BTDFProject"""
        )
        $cmd = $BTDFMSBuild,($arguments -join ' ') -join ' '
        Write-Host $cmd
        $exitCode = (Start-Process -FilePath "$BTDFMSBuild" -ArgumentList $arguments -Wait -PassThru).ExitCode
        Write-Host (Get-Content -Path $DeployResults | Out-String)

        if($exitCode -ne 0) {
            Write-Host "##vso[task.logissue type=error;] Error while calling MSBuild, Exit Code: $exitCode"
            Write-Host ("##vso[task.complete result=Failed;] Deploy-BTDFApplication error while calling MSBuild, Exit Code: {0}" -f $exitCode)
        } else {
            Write-Host "##vso[task.complete result=Succeeded;]DONE"
        }
    }
} else {
    Write-Host ("##vso[task.logissue type=warning;] BTDF application '{0}' not in catalog.  Undeploy skipped." -f $Name)
}