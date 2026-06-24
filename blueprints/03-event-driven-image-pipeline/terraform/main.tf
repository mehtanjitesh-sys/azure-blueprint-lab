terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  storage_name = substr(replace("st${var.resource_prefix}${var.environment}${random_string.suffix.result}", "-", ""), 0, 24)
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.resource_prefix}-${var.environment}"
  location = var.location
}

resource "azurerm_storage_account" "this" {
  name                            = local.storage_name
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "thumbnails" {
  name                  = "thumbnails"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${var.resource_prefix}-${var.environment}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = "web"
}

resource "azurerm_service_plan" "this" {
  name                = "plan-${var.resource_prefix}-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "this" {
  name                = "func-${var.resource_prefix}-${var.environment}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  service_plan_id     = azurerm_service_plan.this.id

  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  https_only                 = true

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "python"
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.this.instrumentation_key
  }
}

