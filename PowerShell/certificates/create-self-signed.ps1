# Variables
$CertName = "SPCert"
$CertPath = "Cert:\CurrentUser\My"
$CertFile = "$PSScriptRoot\SPCert.pfx"
$Password = ConvertTo-SecureString -String "StrongPassword123!" -Force -AsPlainText

# Create self-signed certificate
$cert = New-SelfSignedCertificate -Subject "CN=$CertName" `
    -CertStoreLocation $CertPath `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddYears(1)

# Export certificate to PFX
Export-PfxCertificate -Cert $cert -FilePath $CertFile -Password $Password
# Export public key (.cer) for Azure AD upload
Export-Certificate -Cert $cert -FilePath "$PSScriptRoot\SPCert.cer"