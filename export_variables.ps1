# Get the kube_config output and save it to the specified file
$kube_config = terraform output -raw kube_config
$kube_config | Out-File -FilePath "C:\Users\denis\.kube\config" -Force


$azurerm_key_vault_name = terraform output -raw azurerm_key_vault_name
$k8s_identity_client_id_for_secret_class_assingment = terraform output -raw k8s_identity_client_id_for_secret_class_assingment
$azurerm_key_vault_key_key_name = terraform output -raw azurerm_key_vault_key_key_name
$tenant_id = terraform output -raw tenant_id

# Apply the Kubernetes configuration

kubectl apply -f k8s

# Print the variables to verify the values
Write-Host "azurerm_key_vault_name: $azurerm_key_vault_name"
Write-Host "k8s_identity_client_id_for_secret_class_assignment: $k8s_identity_client_id_for_secret_class_assignment"
Write-Host "azurerm_key_vault_key_key_name: $azurerm_key_vault_key_key_name"
Write-Host "tenant_id: $tenant_id"

