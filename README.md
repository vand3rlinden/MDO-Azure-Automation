# Automate processes in MDO/EOP and Entra ID.

### Disable Shared Mailbox identities with Azure Automation
When you create a new shared mailbox in Exchange Online or with PowerShell, an identity in Entra ID is automatically created and, unfortunately, enabled by default. The identity in Entra ID of a shared mailbox is the same as a normal user, but a shared mailbox doesn't need to be enabled to work.

Disabling shared mailbox identities is recommended to prevent potential abuse by cybercriminals because these accounts aren't protected with MFA.

If you let your IT administrators disable the Shared Mailbox identities they created, it would be simple to forget. The key is to delegate this task to Azure Automation, using a system assigned managed identity.

### Automate DKIM Key Rotation with Azure Automation
DKIM keys, which act as digital signatures for email integrity, must be rotated periodically to minimize the risk of compromise. The recommended frequency is every six months, with the rotation interval tied to the key length - shorter intervals for shorter key lengths. This practice helps defend against potential attacks that target publicly released DKIM keys.

- [Importance of Automated DKIM Key Rotation on dmarcian](https://dmarcian.com/rotate-dkim-key/)
- [Why rotating the DKIM keys is recommended on valimail](https://support.valimail.com/en/articles/9242945-rotating-dkim-keys)
- [Rotate DKIM keys on Microsoft Learn](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-dkim-configure#rotate-dkim-keys)

## Setting up an Automation Account with the necessary permissions
1. Establish a new Automation Account **(System assigned - Managed Identity)**
   
2. Navigate to: **Shared Resource** > **Modules** > **Add a module** > **Browse from gallery** > **Add the list below** > **Runtime version 5.1**
    - `Microsoft.Graph.Authentication`
    - `Microsoft.Graph.Users`
  
3. Install the `ExchangeOnlineManagement 3.5.0` module
 -  Visit https://www.powershellgallery.com/packages/ExchangeOnlineManagement/3.5.0
 -  Choose Deploy to Azure Automation

   > The default ExchangeOnlineManagement module installed from the PowerShell Gallery in Azure Automation is version 3.7.0, which has a [known issue](https://learn.microsoft.com/en-us/answers/questions/1840897/connect-exchangeonline-in-azure-automation-account) since 3.5.1. When you downgrade to ExchangeOnlineManagement 3.5.0, the scripts will work again. Please note that version 3.5.0 will be deployed in PowerShell runtime 5.1, so you’ll also need to create runbooks using the same runtime version.
    
4. Launch PowerShell on your system and establish a connection with Microsoft Graph using the following scopes by executing:
```
Connect-MgGraph -Scopes AppRoleAssignment.ReadWrite.All,Application.Read.All
```

5. After establishing the connection, it's necessary to allocate Exchange Online application permissions to your automation account. Execute the following command:
```
$managedIdentityId = (Get-MgServicePrincipal -Filter "displayName eq 'YOUR-AUTOMATION-ACCOUNT'").Id
$graphApp = Get-MgServicePrincipal -Filter "AppId eq '00000002-0000-0ff1-ce00-000000000000'" #AppId of Office 365 Exchange Online in all Enterprise Applications, always the same in each tenant.
$appRole = $graphApp.AppRoles | Where-Object {$_.Value -eq "Exchange.ManageAsApp"}
New-MgServicePrincipalAppRoleAssignment -PrincipalId $managedIdentityId -ServicePrincipalId $managedIdentityId -ResourceId $graphApp.Id -AppRoleId $appRole.Id
```

6. Once the Exchange Online permissions have been added, proceed to assign Microsoft Graph application permissions to your automation account by running:
> **CAUTION**: Step 6 is only required if you want to implement the Disable Shared Mailbox runbook.
```
$managedIdentityId = (Get-MgServicePrincipal -Filter "displayName eq 'YOUR-AUTOMATION-ACCOUNT'").id
$graphApp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'" #AppId of Microsoft Graph in all Enterprise Applications, always the same in each tenant.
$appRole = $graphApp.AppRoles | Where-Object {$_.Value -eq "User.ReadWrite.All"}
New-MgServicePrincipalAppRoleAssignment -PrincipalId $managedIdentityId -ServicePrincipalId $managedIdentityId -ResourceId $graphApp.Id -AppRoleId $appRole.Id
```

7. Directly assign the Entra ID role ***Exchange Administrator*** to your Automation Account.

## T-DISABLE-SMB.ps1
This runbook enables you to disable Shared Mailbox identities in Entra ID. To configure this in your Automation account, follow the steps below.

1. Create a new Runbook with the following configurations.
      - Name: T-DISABLE-SMB (T stands for tenant shorter)
      - Type: PowerShell
      - Runtime: 5.1

2. You can utilize the runbook to disable all your Shared Mailboxes and assign them a JobTitle by clicking 'Start' in the runbook.

3. Automate the runbook by assigning it a schedule. In your Automation Account, navigate to Shared Resources > Schedules and click 'Add a schedule'.

4. Choose a preferred time, time zone, and set the recurrence to recurring.
     - Example: Daily recurring on 3:00 AM

6. After creating the schedule, open the runbook and navigate to Resources > Schedules.

7. Click on 'Add a schedule,' link the schedule to your runbook, and select the desired schedule.

## T-ROTATE-DKIM-KEYS.ps1
This runbook rotates the DKIM key(s) that are listed in the [Email authentication settings](https://security.microsoft.com/authentication?viewid=DKIM) in MDO. To configure this in your Automation account, follow the steps below.

1. Create a new Runbook with the following configurations.
      - Name: T-ROTATE-DKIM-KEYS (T stands for tenant shorter)
      - Type: PowerShell
      - Runtime: 5.1

2. You can use the runbook to rotate the DKIM key(s) by clicking 'Start' in the runbook.

3. Automate the runbook by assigning it a schedule. In your Automation Account, navigate to Shared Resources > Schedules and click 'Add a schedule'.

4. Choose a preferred time, time zone, and set the recurrence to recurring.
     - Recurring every 3 months - Rotating the DKIM keys every 3 months ensures a complete rotation of both selectors
every 6 months.

6. After creating the schedule, open the runbook and navigate to Resources > Schedules.

7. Click on 'Add a schedule,' link the schedule to your runbook, and select the desired schedule.

