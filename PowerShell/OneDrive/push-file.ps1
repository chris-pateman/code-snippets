$FilePath = ".\pateman.workspace\code-repos\personal\snippets\OldResources.csv"
$OneDriveFolder = "/Documents/AutomationDocuments"
$FileName = "OldResources.csv"
$accessToken = az account get-access-token --query accessToken --output tsv
Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/me/drive/root:$OneDriveFolder/$FileName`:/content" `
    -Headers @{Authorization = "Bearer $accessToken"} `
    -Method PUT `
    -InFile $FilePath `
    -ContentType "application/octet-stream"