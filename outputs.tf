output "app_service_default_hostname" {
  value = azurerm_app_service.app.default_site_hostname
}

output "apim_gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}
