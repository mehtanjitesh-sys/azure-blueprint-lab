variable "location" {
  type        = string
  description = "Azure region for the lab resources."
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "Short environment label."
  default     = "dev"
}

variable "resource_prefix" {
  type        = string
  description = "Prefix used in Azure resource names."
  default     = "blueprint-network"
}

