$conditionAction = "${{ parameters.conditionAction }}"
Write-Host "Should send slack $conditionAction"
if ($conditionAction -eq 'true') {
Write-Host "Sending slack message"

$url = "${{parameters.hookUrl}}"
$title = "${{parameters.title}}"
$message = "${{parameters.message}}"
$emojiIcon = "${{parameters.emojiIcon}}"

try {

    $body = @{
        pretext= "$title"
        text= "$message"
        icon_emoji="$emojiIcon"
    }

    Invoke-RestMethod -Method Post -Uri $url -Body $body -ContentType 'application/json'
    Write-Host "Message has been sent"
}
catch
{
    Write-Error "failed: $_"
    Write-Host "##vso[task.complete result=Failed;]$_."
}
}