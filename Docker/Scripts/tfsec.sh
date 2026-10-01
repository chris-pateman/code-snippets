
tfDir="/mnt/c/Users/patemanc/pateman.workspace/CodeRepo/cp/shared-infrastructure"

$tfsec=$(docker run -t -v "$tfDir:/src" tfsec/tfsec ./src --format JSON --concise-output)


$tfsec | jq --raw-output '.results[].status | length'