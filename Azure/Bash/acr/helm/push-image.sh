export HELM_EXPERIMENTAL_OCI=1

acrName="sdscppublic"
chartPath="./charts/example"
chartName="cp-bookings-api"
imageTag="20220209.2"
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

echo "Push $chartName-$imageTag.tgz to ACR"
helm push $chartName-$imageTag.tgz oci://$acrName.azurecr.io/${repositoryName}