resource "azurerm_resource_group" "vpn" {
  name     = "HomeLab-VPN-ResourceGroup"
  location = "EastUS"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "HomeLab-VirtualNetwork"
  address_space       = ["10.0.0.0/16"] # Azure VNet
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
}

resource "azurerm_virtual_network_dns_servers" "dnsserver" {
  virtual_network_id = azurerm_virtual_network.vnet.id
  dns_servers        = ["192.168.1.1"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet" # This subnet MUST be named "GatewaySubnet"
  address_prefixes     = ["10.0.1.0/24"] # Subnet reserved for VPN Gateway
  resource_group_name  = azurerm_resource_group.vpn.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "vpn_gateway" {
  name                = "home-lab-vpn-gateway-ip"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "vpn-lab-gateway"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "Basic"
  enable_bgp          = false
  active_active       = false

  ip_configuration {
    name                          = "vnet-gateway-config"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    subnet_id                     = azurerm_subnet.gateway.id
  }
}

resource "azurerm_local_network_gateway" "pfsense" {
  name                = "pfsense-gateway"
  location            = azurerm_resource_group.vpn.location
  resource_group_name = azurerm_resource_group.vpn.name
  gateway_address     = var.pfsense_public_ip 
  address_space       = ["192.168.105.0/24"]
}

resource "azurerm_virtual_network_gateway_connection" "vpn_connection" {
  name                        = "connection-to-pfsense"
  location                    = azurerm_resource_group.vpn.location
  resource_group_name         = azurerm_resource_group.vpn.name
  virtual_network_gateway_id  = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id    = azurerm_local_network_gateway.pfsense.id
  type                        = "IPsec"
  shared_key                  = var.vpn_shared_key 
}
