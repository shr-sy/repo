variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "app_service_plan_name" {
  type        = string
  description = "App Service Plan name"
}

# Base name for App Service (will get a random suffix automatically)
variable "app_service_base_name" {
  type        = string
  description = "Base App Service name (suffix will be auto-generated)"
}

# Base name for API Management (will get a random suffix automatically)
variable "apim_base_name" {
  type        = string
  description = "Base APIM name (suffix will be auto-generated)"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD Tenant ID"
}

variable "oauth_client_id" {
  type        = string
  description = "Client ID from Azure AD App Registration"
}

variable "oauth_client_secret" {
  type        = string
  description = "Client Secret from Azure AD App Registration"
  sensitive   = true
}

variable "api_audience" {
  type        = string
  description = "API App ID URI set in Azure AD"
}
