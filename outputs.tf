output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address
}

output "tenant_id" {
  value     = data.azurerm_client_config.current.tenant_id
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "azurerm_key_vault_name" {
  value = azurerm_key_vault.vault.name
}

output "azurerm_key_vault_id" {
  value = azurerm_key_vault.vault.id
}

output "azurerm_assigned_identity_id_for_role_assingment" {
  value = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id      #For role assingment           
}


output "azurerm_key_vault_key_key_name" {
  value = azurerm_key_vault_key.key.name                 
}

output "k8s_identity_client_id_for_secret_class_assingment" {
  value = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].client_id        #For class assingment
}

output "azurerm_kubernetes_cluster_k8s_kube_config_host" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  sensitive = true
}

