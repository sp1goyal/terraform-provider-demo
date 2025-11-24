terraform {
  required_providers {
    btp = {
      source  = "sap/btp"
      version = "~> 1.17.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "~> 1.10.0"
    }
  }
}

provider "btp" {
  username = env("BTP_USERNAME")
  password = env("BTP_PASSWORD")
  globalaccount = env("BTP_GLOBALACCOUNT")
}
provider "cloudfoundry" {
  api_url = env("CF_API_URL")
  user = env("CF_USER")
  password = env("CF_PASSWORD")
  skip_ssl_validation = true
}