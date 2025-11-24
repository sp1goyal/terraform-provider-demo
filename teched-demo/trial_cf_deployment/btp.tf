locals {
  cf_instance_name = "teched-demo-cf-instance"
}

resource "btp_subaccount" "teched-2025" {
  name = "teched-2025"
  region = "eu12"
  subdomain = "teched2025demo"
}

resource "btp_subaccount_role_collection_assignment" "service_admin" {
  subaccount_id        = btp_subaccount.teched-2025.id
  role_collection_name = "Subaccount Service Administrator"
  user_name            = var.btp_username
}

resource "btp_subaccount_entitlement" "cloudfoundry" {
  subaccount_id = btp_subaccount.teched-2025.id
  service_name  = "APPLICATION_RUNTIME"
  plan_name     = "MEMORY"
  # amount        = 6 
} 

data "btp_subaccount_entitlement" "cloudfoundry" {
  subaccount_id = btp_subaccount.teched-2025.id
  service_name  = "APPLICATION_RUNTIME"
  plan_name     = "MEMORY"
}

resource "btp_subaccount_environment_instance" "cloudfoundry" {
  subaccount_id    = btp_subaccount.teched-2025.id
  environment_type = "cloudfoundry"
  name             = "cloudfoundry-for-terraform"
  landscape_label  = var.cf_landscape_label
  plan_name        = "standard"
  service_name     = "cloudfoundry"
  parameters = jsonencode({
    instance_name = local.cf_instance_name
  })
  depends_on = [ btp_subaccount_entitlement.cloudfoundry ]
}