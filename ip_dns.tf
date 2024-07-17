resource "azurerm_public_ip" "ingress_nginx_pip" {
  name                = "ingress-nginx-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}