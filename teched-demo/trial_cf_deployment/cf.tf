resource "cloudfoundry_space" "space" {
    name = "hello-terraform-app"
    org = btp_subaccount_environment_instance.cloudfoundry.platform_id
}

# resource "cloudfoundry_org_role" "my_role" {
#   username = var.btp_username
#   type     = "organization_manager"
#   org      = btp_subaccount_environment_instance.cloudfoundry.platform_id
#   depends_on = [ btp_subaccount_role_collection_assignment.service_admin ]
# }

# resource "cloudfoundry_org_role" "my_role_user" {
#   username = var.btp_username
#   type     = "organization_user"
#   org      = btp_subaccount_environment_instance.cloudfoundry.platform_id
#   depends_on = [ btp_subaccount_role_collection_assignment.service_admin ]
# }

resource "cloudfoundry_space_role" "cf_space_managers" {
  username   = var.btp_username
  type       = "space_manager"
  space      = cloudfoundry_space.space.id
  # depends_on = [cloudfoundry_org_role.my_role, cloudfoundry_org_role.my_role_user]
}

resource "cloudfoundry_space_role" "cf_space_developers" {
  # for_each   = toset(var.cf_space_developers)
  username   = var.btp_username
  type       = "space_developer"
  space      = cloudfoundry_space.space.id
  # depends_on = [cloudfoundry_org_role.my_role, cloudfoundry_org_role.my_role_user]
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

# data "archive_file" "hello-terraform" {
#   type        = "zip"
#   source_dir  = "./assets/helloterraformapp"
#   output_path = "./assets/helloterraform.zip"
# }

resource "cloudfoundry_app" "hello-terraform" {
  name       = "hello-terraform"
  org_name   = local.cf_instance_name
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
  provisioner "local-exec" {
      command = "zip -r ./assets/helloterraformapp.zip ./assets/helloterraform.zip/"
  }
}