# Automate processes in MDO, EOP and Entra ID.
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
