output "public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.web.name
}

