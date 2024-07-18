resource "azurerm_public_ip" "ingress_nginx_pip" {
  name                = "ingress-nginx-pip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}