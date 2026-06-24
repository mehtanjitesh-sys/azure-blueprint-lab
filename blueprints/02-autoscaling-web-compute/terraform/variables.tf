variable "location" {
  type    = string
  default = "eastus"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "resource_prefix" {
  type    = string
  default = "blueprint-webcompute"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "Public SSH key for the VMSS admin user."
  sensitive   = true
}

