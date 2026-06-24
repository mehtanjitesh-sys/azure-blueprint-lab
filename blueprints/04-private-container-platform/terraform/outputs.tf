output "acr_name" {
  value = azurerm_container_registry.this.name
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.this.name
}

