function Get-SslLabsScore {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true,
      ValueFromPipelineByPropertyName = $true,
      ValueFromPipeline = $true,
      Position = 0)]
    [String[]]$UrlList
  )

  Begin {
    [int]$i = 0
  }
  Process {
    Foreach ($Url in $UrlList) {  
      try { 
        $i++ 
        Write-Progress -Activity "Checking URI" -Status "$Url - $i/$(@($UrlList).count) $($i/$(@($UrlList).count)*100 -as [int])%" -PercentComplete ($i / $(@($UrlList).count) * 100 -as [int]) 

        #API Doc https://github.com/ssllabs/ssllabs-scan/blob/master/ssllabs-api-docs-v3.md
        $API = "https://api.ssllabs.com/api/v2/analyze?host=$url&all=on&maxAge=24&"

        $urlStatus = "Starting"
        Write-Host "Requesting $API"
        do {
          $JsonData = Invoke-WebRequest -Uri $API | ConvertFrom-Json 
          $urlStatus = $JsonData.status
          Write-Host "$($Url): Status is $urlStatus, sleeping for 20 seconds" 
          if ($urlStatus -ne "READY") {
            Start-Sleep -seconds 20  
          }
        }
        while ($urlStatus -ne "READY")
              
        Write-Host "Finished"
        Validate-CertificateChain -certificates $JsonData.endpoints[0].details.chain.certs
              
      } 
      catch { 
        Write-Warning -Message "$Url failed: $_ !"
      } 
    }
  }
  End {
  }
}

function Validate-CertificateChain {
  param (
    $certificates
  )
  
  if ($certificates.length -lt 1) {
    Write-Error "No Certificates in the chain"
  }

  foreach ($cert in $certificates) {

    $notBefore = [System.DateTimeOffset]::FromUnixTimeMilliseconds($($cert.notBefore)).DateTime
    $notAfter = [System.DateTimeOffset]::FromUnixTimeMilliseconds($($cert.notAfter)).DateTime
    $current = Get-Date
   
    if ($current -lt $notBefore -or $current -gt $notAfter) {
      Write-Error "$($cert.label) is expired"
    }

    if ($cert.issues -gt 0) {
      Write-Error "$($cert.label) certificate has issues."
    }

  }

}

Get-SslLabsScore -UrlList cvp-recording.aat.platform.cp.net