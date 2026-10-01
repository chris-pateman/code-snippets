Param (
    [string]$path = ".\.aws",
    [string]$fileName = "credentials",
    [string]$accessKeyId,
    [string]$accessKey
)

$awsCredContent = "[Default]
aws_access_key_id=$accessKeyId
aws_secret_access_key=$accessKey" 


$credentialLocation = $path + "/" + $fileName
if (!(Test-Path $credentialLocation))
{
    if (!(Test-Path $path))
    { 
        New-Item -ItemType directory -Path $path
    }
    New-Item -path $path -name $fileName -type "file" -value $awsCredContent
}
else
{
    Clear-Content $credentialLocation
    Add-Content -path $credentialLocation -value $awsCredContent
}