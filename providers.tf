terraform { 
  cloud { 
    
    organization = "Patient-0" 

    workspaces { 
      name = "VPN-Azure" 
    } 
  } 
}

provider "azurerm" {
  features {}
}
