output "app_url" {
  value = "https://${cloudfoundry_route.hello-terraform-route.url}"
}
