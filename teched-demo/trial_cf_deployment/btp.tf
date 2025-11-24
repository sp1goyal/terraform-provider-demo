resource "btp_subaccount" "teched-2025" {
  name = "teched-2025"
  region = "eu12"
  subdomain = "teched2025demo"
}

resource "btp_subaccount_environment_instance" "cloudfoundry" {
  subaccount_id    = btp_subaccount.teched-2025.id
  environment_type = "cloudfoundry"
  name             = "cloudfoundry-for-terraform"
  plan_name        = "standard"
  service_name     = "cloudfoundry"
  parameters = jsonencode({
    instance_name = "teched-demo-cf-instance"
  })
}
