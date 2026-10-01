. "PowerShell/json.ps1"
function AddQueryString{
    Param(
        $name,
        $value
    )

    if ($null -eq $value -or $value -eq "")
    {
        return ""
    }
    else {
        return "$name=$value&"
    }
}

function Request {
    param (
        $requestUrl,
        $requestMethod = 'POST',
        $requestBody,
        $token,
        $tokenType = "Basic",
        $contentType = "application/json"
    )

    Write-Host("requestUrl: $requestUrl")
    Write-Host("requestMethod: $requestMethod")
    Write-Host("Authorization: $tokenType $token")
    Write-Host("contentType: $contentType")
    $authenicationHeader = @{Authorization = "$tokenType $token" }

    try {

        $response = Invoke-WebRequest -Uri $requestUrl -Method $requestMethod -Body ($requestBody | ConvertTo-Json) -ContentType $contentType -Headers $authenicationHeader

        if ((TestJson -text $response)) {
            $response = $response | ConvertFrom-Json
        }

    }
    catch {
        Write-Error "Error in request: $_"
        return {}
    } 

    return $response
}

function GetRequest {
    param (
        $requestUrl,
        $token,
        $tokenType
    )

    return (Request -requestUrl $requestUrl -requestMethod 'GET' -token $token -tokenType $tokenType)
}

function DeleteRequest {
    param (
        $requestUrl,
        $token,
        $tokenType
    )

    return (Request -requestUrl $requestUrl -requestMethod 'DELETE' -token $token -tokenType $tokenType)
}