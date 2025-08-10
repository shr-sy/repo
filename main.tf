terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_app_service_plan" "plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "NODE|18-lts"
  }

  tags = {
    project = "apim-hello"
  }
}

resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = "Dev Team"
  publisher_email     = "dev@example.com"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_api" "api" {
  name                = "hello-world-api"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = "Hello World API"
  path                = "hello"
  protocols           = ["https"]
  revision            = "1"

  # direct backend (App Service)
  service_url = "https://${azurerm_app_service.app.default_site_hostname}"

  # allow calling without subscription key
  subscription_required = false
}

resource "azurerm_api_management_api_policy" "policy" {
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.main.name

  xml_content = <<XML
<policies>
  <inbound>
    <set-header name="X-Example" exists-action="override">
      <value>HelloFromPolicy</value>
    </set-header>
    <base />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
}
