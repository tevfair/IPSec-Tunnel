output "vpn_gateway_IP" {
  description = "PiP of the Azure VPN Gateway"
  value = {
    public_ip = azurerm_public_ip.vpn_gateway.ip_address

  }
}
