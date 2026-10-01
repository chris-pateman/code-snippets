
acrName="${{ parameters.acrName }}"
repositoryName="${{ parameters.repositoryName }}"
imageName="${{ parameters.imageName }}"

docker tag $imageName:latest $acrName.azurecr.io/$repositoryName:${{ tag }}

docker images
az acr login --name sdscppublic
docker push $acrName.azurecr.io/$repositoryName:${{ tag }}