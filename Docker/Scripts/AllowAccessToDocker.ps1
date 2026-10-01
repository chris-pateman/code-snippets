$account="cpateman"
$npipe = "\\.\pipe\docker_engine"                                                                                 
$dInfo = New-Object "System.IO.DirectoryInfo" -ArgumentList $npipe                                               
$dSec = $dInfo.GetAccessControl()                                                                                 
$fullControl =[System.Security.AccessControl.FileSystemRights]::FullControl                                       
$allow =[System.Security.AccessControl.AccessControlType]::Allow                                                  
$rule = New-Object "System.Security.AccessControl.FileSystemAccessRule" -ArgumentList $account,$fullControl,$allow
$dSec.AddAccessRule($rule)                                                                                        
$dInfo.SetAccessControl($dSec)