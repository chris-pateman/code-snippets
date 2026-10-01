
          $profiles = @{
              default = "DEFAULT"
          };

          $profile = $profiles.default;
          
          $owner = "acc_devops_engineer";
          $names = @(
              "uat_externallocation"
          );
  
          foreach ($name in $names) {
            Write-Host "name is $name";
            Write-Host "owner is $owner";
            databricks external-locations update $name --owner $owner --profile $profile;
        };

