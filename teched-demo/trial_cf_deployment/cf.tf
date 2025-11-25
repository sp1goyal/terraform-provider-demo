resource "cloudfoundry_space" "space" {
    name = "hello-terraform-app"
    org = btp_subaccount_environment_instance.cloudfoundry.platform_id
}

resource "cloudfoundry_space_role" "cf_space_managers" {
  username   = var.btp_username
  type       = "space_manager"
  space      = cloudfoundry_space.space.id
}

resource "cloudfoundry_space_role" "cf_space_developers" {
  username   = var.btp_username
  type       = "space_developer"
  space      = cloudfoundry_space.space.id
}

data "cloudfoundry_domain" "domain" {
  name = "cfapps.${btp_subaccount.teched-2025.region}.hana.ondemand.com"
}

resource "cloudfoundry_route" "hello-terraform-route" {
  domain = data.cloudfoundry_domain.domain.id
  space  = cloudfoundry_space.space.id
  host   = "hello-terraform-2025"
  depends_on = [ cloudfoundry_space_role.cf_space_managers, cloudfoundry_space_role.cf_space_developers ]
}

data "cloudfoundry_service_plan" "xsuaa" {
  name                  = "application"
  service_offering_name = "xsuaa"
}

resource "cloudfoundry_service_instance" "hello-terraform-xsuaa" {
  name         = "hello-terraform-xsuaa"
  space        = cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service_plan.xsuaa.id
  depends_on = [ cloudfoundry_space_role.cf_space_managers ]
  type         = "managed"
  parameters = jsonencode({
    xsappname   = "hello-terraform-2025"
    tenant-mode = "shared"
    scopes = [
      {
        name        = "hello-terraform-2025.Display"
        description = "Display"
      },
    ]
    role-templates = [
      {
        name        = "Viewer"
        description = ""
        scope-references = [
          "hello-terraform-2025.Display"
        ]
      }
    ]
  })
}

resource "cloudfoundry_app" "hello-terraform" {
  name       = "hello-terraform"
  org_name   = local.cf_instance_name
  space_name = cloudfoundry_space.space.name
  buildpacks = ["nodejs_buildpack"]
  memory     = "512M"
  path       = "./assets/helloterraform.zip"
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