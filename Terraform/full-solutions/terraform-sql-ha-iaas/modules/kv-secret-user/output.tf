output "username" {
  value = local.user_name
}
output "password" {
  value     = random_password.pass.result
  sensitive = true
}