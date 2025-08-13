variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
  default     = "rg-policy-test"
}

variable "location" {
  type        = string
  description = "Azure location"
  default     = "eastus"
}

variable "app_service_plan_name" {
  type        = string
  description = "App Service Plan name"
  default     = "asp-policy-test"
}

variable "app_service_name" {
  type        = string
  description = "App Service name"
  default     = "app-policy-test"
}

variable "apim_name" {
  type        = string
  description = "API Management service name"
  default     = "apim-policy-test"
}
