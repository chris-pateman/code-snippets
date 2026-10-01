Param (
    [string]$hostname = "rabbitMq",
    [string]$containerName = "rabbitMq",
    [string]$imageName = "rabbitmq",
    [int]$managementPort = 8081
)

Write-Host("Running:")
Write-Host("docker run --rm -d --hostname $hostname --name $containerName -p $managementPort`:15672 $imageName")
$containerId = (docker run --rm -d --hostname $hostname --name $containerName -p $managementPort`:15672 $imageName )

Write-Host("Got container $containerId")
