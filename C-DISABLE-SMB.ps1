#Connect EXO
Connect-ExchangeOnline -ManagedIdentity -Organization yourorg.onmicrosoft.com

#Connect to Microsoft Graph
Connect-MgGraph -Identity

#Get all shared mailboxes
$SMBS = (Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited).UserPrincipalname

#Set all SMBS on Jobtitle Shared Mailbox and set AccountEnabled on false
ForEach ($SMB in $SMBS) {
    Update-MgUser -UserId $SMB -JobTitle "Shared Mailbox" -AccountEnabled:$false
}

#To prevent the script from failing with a maximum of 3 allowed connections to EXO.
Get-PSSession | Remove-PSSession
