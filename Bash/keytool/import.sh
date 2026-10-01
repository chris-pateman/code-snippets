pfxPath="/mnt/c/Users/patemanc/AppData/Local/Posh-ACME/LE_STAGE/36147648/cvp-recording.sandbox.platform.cp.net/cert.pfx"
password="poshacme"
destination="/mnt/c/Users/patemanc/pateman.workspace/CodeSnippets/snippets/Bash/keytool/generated/exported.jks"
keytool -importkeystore -srckeystore $pfxPath -srcstoretype pkcs12 -destkeystore $destination -deststoretype JKS -deststorepass $password -srcstorepass $password

