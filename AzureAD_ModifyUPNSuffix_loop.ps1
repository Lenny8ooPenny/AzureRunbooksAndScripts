#Create and Register App first (App Registrations). Set API Permissions for Application. Create Secret, copy value. 
#Notes: Using PowerShell 5, with graph auth 5, users 5, msal 5.
$AppId = '##################'
$TenantId = '##################'
$ClientSecret = '##################'

Import-Module MSAL.PS
$MsalToken = Get-MsalToken -TenantId $TenantId -ClientId $AppId -ClientSecret ($ClientSecret | ConvertTo-SecureString -AsPlainText -Force)

#Connecting to the Graph to get users and modify.
Connect-Graph -AccessToken $MsalToken.AccessToken

#example
$oldUPNSuffix = "@Leokrische24gmail.onmicrosoft.com"
$newUPNSuffix = "@LEOkrische24gmail.onmicrosoft.com"

$users = Get-MgUser -All | Where {$_.UserPrincipalName -cmatch "$oldUPNSuffix"} | select givenname, surname, UserPrincipalName, Id 
#$users

foreach ($user in $users){
    $UserLogonName = $user.UserPrincipalName -replace $oldUPNSuffix,'' ##Gets rid of the upn suffix so you get the user logon name section. 
                                                    #It looks for $oldupnsuffix in the string and replaces it with nothing, basically removing it from the string so you get the original user logon name.
    $UserLogonName                                  #Stores the userlogonname in the variable for later.
    $Newname = $UserLogonName +  $newUPNSuffix      #Creates the new UPN with the same user logon name but adds the new UPN suffix.
    $Newname                                        #prints out the new complete UserPrincipalName. Use this to test and see if it’s what you want
    Update-MgUser -UserId $users.Id -UserPrincipalName $newupn #Add the new upn you created in the step before as the current upn for the user.
    }

	
#https://thesysadminchannel.com/how-to-connect-to-microsoft-graph-api-using-powershell/#:~:text=Connect%20to%20Microsoft%20Graph%20API%20Using%20Interactive%20Logon,pops%20up%204%20You%20should%20see%20authentication%20complete
#https://learn.microsoft.com/en-us/powershell/microsoftgraph/app-only?view=graph-powershell-1.0&tabs=azure-portal#see-also
#https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/update-mguser?view=graph-powershell-1.0
