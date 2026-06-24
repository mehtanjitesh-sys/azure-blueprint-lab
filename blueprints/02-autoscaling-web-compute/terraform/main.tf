terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  cloud_init = base64encode(<<-EOT
    #cloud-config
    package_update: true
    packages:
      - nginx
    runcmd:
      - systemctl enable nginx
      - systemctl start nginx
      - echo "Azure Blueprint Lab VMSS" > /var/www/html/index.html
  EOT
  )
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.resource_prefix}-${var.environment}"
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.resource_prefix}-${var.environment}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_public_ip" "this" {
  name                = "pip-${var.resource_prefix}-${var.environment}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "this" {
  name                = "lb-${var.resource_prefix}-${var.environment}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.this.id
  }
}

resource "azurerm_lb_backend_address_pool" "web" {
  name            = "web-backend"
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_probe" "http" {
  name            = "http-probe"
  loadbalancer_id = azurerm_lb.this.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "http" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                = "vmss-${var.resource_prefix}-${var.environment}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = var.admin_username
  custom_data         = local.cloud_init

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "nic-web"
    primary = true

    ip_configuration {
      name                                   = "ipconfig"
      primary                                = true
      subnet_id                              = azurerm_subnet.web.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web.id]
    }
  }
}

