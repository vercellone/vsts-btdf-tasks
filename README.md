# Deployment Framework for BizTalk VSTS release tasks

This extension facilitates the release (not build) of BizTalk applications to server(s) with a [private agent](https://www.visualstudio.com/en-us/docs/build/concepts/agents/agents) (deployment group members qualify).  It started as a decomposition of the monolithic [Install-BizTalkApplication](http://biztalkalm.codeplex.com/SourceControl/latest#Prod/BuildScripts/Install-BizTalkApplication.ps1) PowerShell script into more granular tasks for greater flexibility and enhanced feedback within the scope of a vsts release.


## Tasks
1. **BTDF Deploy**

   Deployment Framework for BizTalk btdfproj project target: Deploy.

1. **BTDF Undeploy**

   Deployment Framework for BizTalk btdfproj project target: Undeploy.

1. **MSI Install**

   Install *any* MSI using the command msiexec.exe /i [msi file].  Not limited to MSIs built by BTDF.

1. **MSI Uninstall**
    
    Uninstall *any* MSI using the command msiexec.exe /x[InstallGuid].  Not limited to MSIs built by BTDF.

1. **Terminate Suspended**

   Terminate suspended service instances and optionally save the relevant messages and metadata.

   BTDF Undeploy will fail if there are any suspended service instances associated with the BizTalk application being deployed.  This task terminates and (by default) saves the messages and metadata to disk for future reference.

## Typical Usage

   ### For a simple, standalone BizTalk application

   1. Terminate Suspended
       * Save messages checked for production, unchecked for non-production.
   1. BTDF Undeploy
   1. MSI Uninstall
   1. MSI Install
   1. BTDF Deploy

   ### For BizTalk applications referenced by other BizTalk applications.  (i.e. projects B and C both reference project A)

   1. Terminate Suspended
       * Save messages checked for production, unchecked for non-production.
   1. BTDF Undeploy C
   1. BTDF Undeploy B
   1. BTDF Undeploy A
   1. MSI Uninstall A
   1. MSI Install A
   1. BTDF Deploy A
   1. BTDF Deploy B
   1. BTDF Deploy C
 
## See Also
* [Deployment Framework for BizTalk Visual Studio extensions](https://marketplace.visualstudio.com/items?itemName=DeployFxForBizTalkTeam.DeploymentFrameworkforBizTalk)
* [Deployment Framework for BizTalk (BTDF)](http://biztalkdeployment.codeplex.com/)
* [Deployment Framework For BizTalk Documentation](http://www.tfabraham.com/blog/deployment-[framework-for-biztalk-documentation/)
* [Understanding the BizTalk Deployment Framework – Introduction](https://blogs.biztalk360.com/understanding-biztalk-deployment-framework-introduction/)
* [BizTalk ALM with VSTS](http://biztalkersblog.azurewebsites.net/biztalk-alm-with-visual-studio-online/)
* [BizTalk Application Deployment using BTDF and PowerShell](https://vikas15bhardwaj.wordpress.com/2015/02/06/biztalk-application-deployment-using-btdf-and-powershell/)
