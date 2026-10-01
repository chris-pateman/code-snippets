Param {
  [string]$password,
  [string]$pfxLocation
}


$pass = ConvertTo-SecureString $password -AsPlainText -Force
Import-PfxCertificate -FilePath $pfxLocation -CertStoreLocation Cert:\LocalMachine\My -Password $pass