acrName="sdscppublic"
chartPath="./charts/example"
chartName="cp-bookings-api"
imageTag="20220209.5"
repositoryName="cp/bookings-api"

echo "Sign into ${acrName}"
az acr login --name $acrName

REPOTRIM="$(echo $chartName | sed 's/-//g')"

echo "Add Helm Repo to ACR"
helm repo add $acrName https://$acrName.azurecr.io/helm/v1/repo

cd $chartPath

echo "Update Dependencys"
helm dependency update

echo "Package Chart in ${chartPath}"
helm package . --version $imageTag

echo "Push to ACR with tag $imageTag"
az acr helm push -n $acrName $chartName-$imageTag.tgz
        