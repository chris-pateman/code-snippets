
tfDir="${TF_DIR:-.}"

tfsec=$(docker run -t -v "$tfDir:/src" tfsec/tfsec ./src --format JSON --concise-output)


echo "$tfsec" | jq --raw-output '.results[].status | length'