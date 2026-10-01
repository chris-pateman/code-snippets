$outputReport=$false
$currentDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)



Write-Host "Run Report"
$tfDir="./pateman.workspace\code-repos\version1\tf-module-template"

if ($outputReport -eq $true) {

  $reportPath="$currentDir/TFSecReport"
  Write-Host "Make Directory - $reportPath"
  If (!(test-path $path))
  {
      mkdir $reportPath
  }

  docker run --rm -t -v $tfDir`:/src tfsec/tfsec ./src --format JUnit > $reportPath/TFSecReport/junit.xml
} else {
  docker run --rm -t -v $tfDir`:/src tfsec/tfsec ./src 
}
