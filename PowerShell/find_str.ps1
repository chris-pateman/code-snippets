

Get-ChildItem -Recurse | Select-String "`"YY-MM-DD'T'HH:MM:ssZ" -List | Select Path