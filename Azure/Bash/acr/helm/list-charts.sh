acrName="sdscppublic"
repositoryName="cp/bookings-api"

az acr repository show-manifests --name $acrName --repository $repositoryName --detail
