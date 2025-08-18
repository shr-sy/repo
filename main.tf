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
resource "azurerm_api_management_api" "api" {
  name                = "hello-world-api"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Hello World API"
  path                = "hello"
  protocols           = ["https"]

  service_url = "https://${azurerm_linux_web_app.app.default_hostname}"

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

resource "azurerm_api_management_authorization_server" "oauth_server" {
  name                = "my-oauth-server"
  resource_group_name = azurerm_resource_group.main.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = "My OAuth 2.0 Server"

  authorization_endpoint        = "https://login.microsoftonline.com/${var.tenant_id}/oauth2/v2.0/authorize"
  token_endpoint                = "https://login.microsoftonline.com/${var.tenant_id}/oauth2/v2.0/token"
  
  # informational URL (required)
  client_registration_endpoint  = "https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade"

  grant_types = [
    "authorizationCode",
    "clientCredentials"
  ]

  client_id     = var.oauth_client_id
  #client_secret = var.oauth_client_secret

  authorization_methods = ["GET", "POST"]

  # Recommended to explicitly specify how token is sent back
  bearer_token_sending_methods = ["authorizationHeader"]
}

resource "azurerm_api_management_api_policy" "policy_oauth" {
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.main.name

  #xml_content = <<XML
#<policies>
  #<inbound>
    #<base />
    #<validate-jwt header-name="Authorization"
                  #failed-validation-httpcode="401"
                  #failed-validation-error-message="Unauthorized. Access token is missing or invalid."
                  #require-expiration-time="true"
                  #require-scheme="Bearer"
                  #require-signed-tokens="true">
      #<openid-config url="https://login.microsoftonline.com/${var.tenant_id}/v2.0/.well-known/openid-configuration" />
      #<audiences>
        #<audience>${var.api_audience}</audience>
      #</audiences>
    #</validate-jwt>
  #</inbound>
  #<backend>
    #<forward-request />
  #</backend>
  #<outbound>
    #<base />
  #</outbound>
  #<on-error>
    #<base />
  #</on-error>
#</policies>
#XML

xml_content = <<XML
<policies>
  <inbound>
    <base />
    <!-- Check for Authorization header -->
    <check-header name="Authorization" failed-check-httpcode="401" failed-check-error-message="Access denied - Missing Authorization header" ignore-case="false" />
    
    <!-- Forward Authorization header as-is to backend -->
    <set-header name="X-User-Token" exists-action="override">
      <value>@(context.Request.Headers.GetValueOrDefault("Authorization",""))</value>
    </set-header>
    
    <!-- CORS headers -->
    <cors>
      <allowed-origins>
        <origin>*</origin>
      </allowed-origins>
      <allowed-methods>
        <method>GET</method>
        <method>POST</method>
        <method>PUT</method>
        <method>DELETE</method>
        <method>OPTIONS</method>
      </allowed-methods>
      <allowed-headers>
        <header>Authorization</header>
        <header>Content-Type</header>
        <header>Ocp-Apim-Subscription-Key</header>
      </allowed-headers>
      <expose-headers>
        <header>X-User-Token</header>
      </expose-headers>
    </cors>
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
