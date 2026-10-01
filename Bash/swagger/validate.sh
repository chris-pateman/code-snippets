
url="https://raw.githubusercontent.com/cp/resources/swagger/api-swagger.json"

CHECK=$(curl -X "GET" "https://validator.swagger.io/validator/debug?url=${url}" --silent)
if [[ $CHECK != "{}" ]]; then 
  echo -e "\nSorry this is an invalid Swagger:\n$CHECK\n"
  exit 1
fi;