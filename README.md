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
    - ExchangeOnlineManagement
    - Microsoft.Graph.Authentication
    - Microsoft.Graph.Users
    
3. Launch PowerShell on your system and establish a connection with Microsoft Graph using the following scopes by executing.
  ```
  Connect-MgGraph -Scopes AppRoleAssignment.ReadWrite.All,Application.Read.All
  ```
