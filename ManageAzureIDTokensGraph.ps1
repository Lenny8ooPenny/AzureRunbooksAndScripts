#Used PowerShell runtime 5.1
#modules: Authentication for PS 5.1 v 1.13, and groups.
#Managed Identity needs Microsoft Graph 'User.Read.All' with admin consent. Follow https://aztoso.com/security/microsoft-graph-permissions-managed-identity/
#Needs Group Object ID

try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$token = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com"
Connect-MgGraph -AccessToken $token.Token 

Get-MgDeviceManagementManagedDevice -All

$group = Get-MgGroup -GroupId '#######################'
$members = Get-MgGroupMember -GroupId $group.Id
$Id = $members | select Id
$Id

Select-MgProfile -Name "beta"

foreach ($member in $members){
    Invoke-MgInvalidateUserRefreshToken -UserId $member.Id
}
