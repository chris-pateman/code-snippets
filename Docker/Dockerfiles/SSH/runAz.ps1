
$name = "sshaz"
docker build -t $name -f Dockerfile.az .
docker run -d -P --name $name -p 52022:22 $name
