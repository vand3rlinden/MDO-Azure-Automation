#Connect EXO
Connect-ExchangeOnline -ManagedIdentity -Organization yourorg.onmicrosoft.com

#Rotatge the DKIM key
Rotate-DkimSigningConfig -KeySize 2048 -Identity "yourdomain.com"
