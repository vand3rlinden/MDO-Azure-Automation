#Connect EXO
Connect-ExchangeOnline -ManagedIdentity -Organization yourorg.onmicrosoft.com #Add your organization's MOERA domain

#Rotate the DKIM keys for all enabled domains
$Domains = (Get-DkimSigningConfig | Where-Object {$_.Enabled -eq 'True'}).domain

foreach ($domain in $domains){
    Rotate-DkimSigningConfig -KeySize 2048 -Identity $domain
}
