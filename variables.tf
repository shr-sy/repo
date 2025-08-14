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

variable "app_service_name" {
  type        = string
  description = "App Service name"
}

variable "apim_name" {
  type        = string
  description = "API Management name"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD Tenant ID"
}

#variable "oauth_client_id" {
#  type        = string
#  description = "Client ID from Azure AD App Registration"
#}

variable "api_audience" {
  type        = string
  description = "API App ID URI set in Azure AD"
}
