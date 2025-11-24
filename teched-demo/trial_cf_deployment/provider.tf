terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      # version = "1.17.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      # version = "1.10.0"
    }
  }
}

provider "btp" {
  cli_server_url = var.cli_server_url
  username = var.btp_username
  password = var.btp_password
  globalaccount = var.btp_globalaccount
}
provider "cloudfoundry" {
  api_url = var.cf_api_url
  user = var.cf_user
  password = var.cf_password
  skip_ssl_validation = true
}
