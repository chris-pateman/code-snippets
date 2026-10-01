
$secretArr=@();
$envs = Get-ChildItem env:* | sort-object name
Foreach ($env in $envs) { 
  $name=$env.Name 
  if ($name -like "tf_secret_*"){
    $value=$env.Value
    Write-Host "adding: $name"
    Write-Host ""
    $secretArr += @{
      name = $name
      value = $value
    }
  }
}

secretArr=$(env -0 | while IFS='=' read -r -d '' n v; do
        envName="$n"
        #echo "processing $envName"
        if [[ "${envName}" == 'tf_secret_'* ]]; then
          envName="${envName//tf_secret_/}"
          envValue="$v"
          #echo "found $envName"
          echo "{\\\"name\\\":\\\"$envName\\\",\\\"value\\\":\\\"$envValue\\\"},"
          #echo "found $secretArr"
        fi
      done)

variable="name1,name2"
secretArr=$(for i in ${variable//,/ }
do
  echo "{\\\"name\\\":\\\"$i\\\",\\\"value\\\":\\\"$($i)\\\"},"
done)
secretArr="[${secretArr}]"
variables="${variables} -var \"secrets_arr=${secretArr}\""
