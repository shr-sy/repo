terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1️⃣ Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# 2️⃣ Service Plan (Linux)
resource "azurerm_service_plan" "plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# 3️⃣ Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}

# 4️⃣ API Management Instance
resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = "Dev Team"
  publisher_email     = "dev@example.com"
  sku_name            = "Developer_1"
}

# 5️⃣ API linked to Web App
# 5️⃣ API linked to Web App (Option 2 - Inline OpenAPI)
resource "azurerm_api_management_api" "api" {
  name                = "hello-world-api"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Hello World API"
  path                = "hello"
  protocols           = ["https"]

  import {
    content_format = "openapi+json"
    content_value  = <<EOT
{
  "openapi": "3.0.1",
  "info": {
    "title": "Hello World API",
    "version": "1.0.0"
  },
  "paths": {
    "/": {
      "get": {
        "responses": {
          "200": {
            "description": "OK"
          }
        }
      }
    }
  }
}
EOT
  }
}


# 6️⃣ API Policy
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
