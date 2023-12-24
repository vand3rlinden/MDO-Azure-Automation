# Automate processes in MDO, EOP and Entra ID.

### Disable Shared Mailbox identities with Azure Automation
When you create a new Shared Mailbox in Exchange Online (or with PowerShell), an identity is automatically created in Entra ID, with a randomly password. The identity of a Shared Mailbox is the same as a normal user, but a Shared Mailbox don’t need to be enabled to work.

Disabling the Shared Mailbox identities is advised to prevent any potential abuse by cyber criminals.

If you let your IT administrators disable the Shared Mailbox identities they created, it would be simple to forget. The key is to delegate this task to Azure Automation, using a system assigned managed identity.

### Automate DKIM Key Rotation with Azure Automation
DKIM keys, acting as digital signatures for email integrity, need periodic rotation to minimize the risk of compromise. The recommended frequency, is every six months, with the rotation interval tied to the key length—shorter intervals for shorter key lengths. This practice helps defend against potential attacks targeting publicly published DKIM keys.


## Setting up an Automation Account with the necessary permissions
1. Establish a new Automation Account (System assigned)
   
2. Navigate to Shared Resource > Modules > Add a module > Browse from gallery > add the list below > Runtime version 7.2
    - ```ExchangeOnlineManagement```
    - ```Microsoft.Graph.Authentication```
    - ```Microsoft.Graph.Users```
    
3. Launch PowerShell on your system and establish a connection with Microsoft Graph using the following scopes by executing.
```
Connect-MgGraph -Scopes AppRoleAssignment.ReadWrite.All,Application.Read.All
```

4. After establishing the connection, it's necessary to allocate Exchange Online application permissions to your automation account. Execute the following command.
```
$managedIdentityId = (Get-MgServicePrincipal -Filter "displayName eq 'YOUR-AUTOMATION-ACCOUNT'").id
$graphApp = Get-MgServicePrincipal -Filter "AppId eq '00000002-0000-0ff1-ce00-000000000000'" #AppId of Office 365 Exchange Online in all Enterprise Applications, always the same in each tenant.
$graphScopes = @(
    'Exchange.ManageAsApp'
)

ForEach($scope in $graphScopes){
  $appRole = $graphApp.AppRoles | Where-Object {$_.Value -eq $scope}
  New-MgServicePrincipalAppRoleAssignment -PrincipalId $managedIdentityId -ServicePrincipalId $managedIdentityId -ResourceId $graphApp.Id -AppRoleId $appRole.Id
}
```

5. Once the Exchange Online permissions have been added, proceed to assign Microsoft Graph application permissions to your automation account by running.
```
$managedIdentityId = (Get-MgServicePrincipal -Filter "displayName eq 'YOUR-AUTOMATION-ACCOUNT'").id
$graphApp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'" #AppId of Microsoft Graph in all Enterprise Applications, always the same in each tenant.
$graphScopes = @(
    'User.ReadWrite.All'
)

ForEach($scope in $graphScopes){
  $appRole = $graphApp.AppRoles | Where-Object {$_.Value -eq $scope}
  New-MgServicePrincipalAppRoleAssignment -PrincipalId $managedIdentityId -ServicePrincipalId $managedIdentityId -ResourceId $graphApp.Id -AppRoleId $appRole.Id
}
```

6. Directly assign the Entra ID role "Exchange Administrator" to your Automation Account.

## C-DISABLE-SMB.ps1
This runbook enables you to disable Shared Mailbox identities in Entra ID. To configure this in your Automation account, follow the steps below.

1. Create a new Runbook with the following configurations.
      - Name: C-DISABLE-SMB (C stands for tenant shorter)
      - Type: PowerShell
      - Runtime: 7.2

2. You can utilize the runbook to disable all your Shared Mailboxes and assign them a JobTitle by clicking 'Start' in the runbook.

3. Automate the runbook by assigning it a schedule. In your Automation Account, navigate to Shared Resources > Schedules and click 'Add a schedule'.

4. Choose a preferred time, time zone, and set the recurrence to recurring.
     - Example: Daily recurring on 3:00 AM

6. After creating the schedule, open the runbook and navigate to Resources > Schedules.

7. Click on 'Add a schedule,' link the schedule to your runbook, and select the desired schedule.

## C-ROTATE-DKIM-KEYS.ps1
This runbook rotates the DKIM key(s) that are listed in the [Email authentication settings](https://security.microsoft.com/authentication?viewid=DKIM) in MDO. To configure this in your Automation account, follow the steps below.

1. Create a new Runbook with the following configurations.
      - Name: C-ROTATE-DKIM-KEYS (C stands for tenant shorter)
      - Type: PowerShell
      - Runtime: 7.2

2. You can use the runbook to rotate the DKIM key(s) by clicking 'Start' in the runbook.

3. Automate the runbook by assigning it a schedule. In your Automation Account, navigate to Shared Resources > Schedules and click 'Add a schedule'.

4. Choose a preferred time, time zone, and set the recurrence to recurring.
     - Example: Recurring every 6 months

6. After creating the schedule, open the runbook and navigate to Resources > Schedules.

7. Click on 'Add a schedule,' link the schedule to your runbook, and select the desired schedule.

