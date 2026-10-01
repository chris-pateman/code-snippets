$currentDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

Set-Location "$currentDir/../.."
$location = Get-Location
Write-Host "Location: $location"

Write-Host "TF Init"
terraform fmt -recursive
terraform init

Write-Host "TF Plan"
$planPath = "resources/plans/local-output.tfpan"
terraform plan -out $planPath -var-file "resources/environments/local.tf" -input=false

Write-Host "TF Apply"
terraform apply $planPath