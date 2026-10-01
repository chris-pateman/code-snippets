pfxPath="${PFX_PATH:?Set PFX_PATH to the source certificate}"
password="${PFX_PASSWORD:?Set PFX_PASSWORD to the source certificate password}"
destination="${JKS_PATH:-./generated/exported.jks}"
keytool -importkeystore -srckeystore $pfxPath -srcstoretype pkcs12 -destkeystore $destination -deststoretype JKS -deststorepass $password -srcstorepass $password

