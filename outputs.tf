output "app_service_default_hostname" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "apim_gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "app_service_name" {
  value = azurerm_linux_web_app.app.name
}
