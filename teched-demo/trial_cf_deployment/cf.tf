resource "cloudfoundry_space" "space" {
    name = "hello-terraform-app"
    org = btp_subaccount_environment_instance.cloudfoundry.platform_id
}

data "cloudfoundry_domain" "domain" {
  name = "cfapps.${btp_subaccount.teched-2025.region}.hana.ondemand.com"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "cloudfoundry_route" "hello-terraform-route" {
  domain = data.cloudfoundry_domain.domain.id
  space  = cloudfoundry_space.space.id
  host   = "hello-terraform-${random_id.suffix.hex}"
}

data "cloudfoundry_service_plan" "xsuaa" {
  name                  = "application"
  service_offering_name = "xsuaa"
}

resource "cloudfoundry_service_instance" "hello-terraform-xsuaa" {
  name         = "hello-terraform-xsuaa"
  space        = cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service_plan.xsuaa.id
  type         = "managed"
  parameters = jsonencode({
    xsappname   = "hello-terraform-${random_id.suffix.hex}"
    tenant-mode = "shared"
    scopes = [
      {
        name        = "hello-terraform-${random_id.suffix.hex}.Display"
        description = "Display"
      },
    ]
    role-templates = [
      {
        name        = "Viewer"
        description = ""
        scope-references = [
          "hello-terraform-${random_id.suffix.hex}.Display"
        ]
      }
    ]
  })
}

data "archive_file" "hello-terraform" {
  type        = "zip"
  source_dir  = "./assets/helloterraformapp"
  output_path = "./assets/helloterraform.zip"
}

resource "cloudfoundry_app" "hello-terraform" {
  name       = "hello-terraform"
  org_name   = btp_subaccount_environment_instance.cloudfoundry.platform_id
  space_name = cloudfoundry_space.space.name
  buildpacks = ["nodejs_buildpack"]
  memory     = "512M"
  path       = data.archive_file.hello-terraform.output_path
  service_bindings = [
    {
      service_instance = cloudfoundry_service_instance.hello-terraform-xsuaa.name
    }
  ]
  routes = [
    {
      route = cloudfoundry_route.hello-terraform-route.url
    }
  ]
}