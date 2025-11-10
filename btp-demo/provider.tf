terraform {
  required_providers {
    btp = {
      source  = "sap/btp"
      version = "~> 1.17.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "~> 1.9.0"
    }
  }
}

provider "btp" {
  globalaccount = var.globalaccount
}
provider "cloudfoundry" {
  api_url = "https://api.cf.${var.region}-001.hana.ondemand.com"
  skip_ssl_validation = true
}