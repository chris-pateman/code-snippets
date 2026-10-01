$application_id = "ea6bdd71-6014-4154-be17-72a539e92190"
$lifetime_seconds = "100"
$comment = "CP Test"
$profile_name = "adb-264743555852348"

databricks token-management create-obo-token $application_id --lifetime-seconds $lifetime_seconds --comment $comment -p $profile_name --debug
