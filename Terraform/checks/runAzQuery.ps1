param (
    [string]$query
)

$rs = Invoke-Expression "$query --only-show-errors"
$object = $rs  | ConvertFrom-Json
$object.PSObject.Properties | ForEach-Object {
    if ($null -eq $object.$($_.Name)) {
        $object.$($_.Name) = ""
    }
    elseif ($object.$($_.Name).GetType().Name -eq "Object[]") {
        $object.PSObject.Properties.Remove($($_.Name))
    }
    else {
        $object.$($_.Name) = $object.$($_.Name).ToString()
    }
}
$jsonStringValues = $object | ConvertTo-Json
$jsonStringValues