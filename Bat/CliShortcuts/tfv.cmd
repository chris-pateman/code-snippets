@echo off
echo ------------------TF INIT------------------
terraform init --backend=false
echo ------------------TF FMT------------------
terraform fmt --recursive
echo ------------------TF VALIDATE------------------
terraform validate
echo ------------------TF COMPLETED------------------
