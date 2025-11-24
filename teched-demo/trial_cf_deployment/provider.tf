terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "1.17.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.10.0"
    }
  }
}

# Configure the BTP Provider
provider "btp" {
  cli_server_url = "https://canary.cli.btp.int.sap"
  globalaccount = "terraformdemocanary"
}

provider "cloudfoundry" {
  api_url = "https://api.cf.eu12.hana.ondemand.com"
}
