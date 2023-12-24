#Connect EXO
. .\Login-EXO.ps1

#Connect to Microsoft Graph
. .\Login-MgGraph.ps1

#Get all shared mailboxes
$SMBS = (Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited).UserPrincipalname

#Set all SMBS on Jobtitle Shared Mailbox and set AccountEnabled on false
ForEach ($SMB in $SMBS) {
    Update-MgUser -UserId $SMB -JobTitle "Shared Mailbox" -AccountEnabled:$false
}

#To prevent the script from failing with a maximum of 3 allowed connections to EXO.
Get-PSSession | Remove-PSSession
