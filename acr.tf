resource "azurerm_container_registry" "acr" {
  name                = coalesce(var.acr_name, "acr${random_string.azurerm_key_vault_name.result}")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard"
  admin_enabled       = true
}

# add the role to the identity the kubernetes cluster was assigned
resource "azurerm_role_assignment" "k8s_to_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  depends_on = [ 
    azurerm_container_registry.acr
   ]
}