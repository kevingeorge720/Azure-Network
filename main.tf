resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "assigment5-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [each.value.cidr]


  dynamic "delegation" {
    for_each = each.value.delegated ? [each.key] : []
    content {
      name = "${each.key} - delegation"
      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
  service_endpoints = ["Microsoft.Storage"]
}
# Create a Network Security Group (NSG)
resource "azurerm_network_security_group" "example" {
  name                = "my-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a Route Table
resource "azurerm_route_table" "example" {
  name                = "kevin-route-table"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "0.0.0.0"
  }
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}
# Associate NSG and Route Table with subnets
resource "azurerm_subnet_network_security_group_association" "example" {
  for_each                = var.subnets
  subnet_id               = azurerm_subnet.example[each.key].id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_subnet_route_table_association" "example" {
  for_each                = var.subnets
  subnet_id               = azurerm_subnet.example[each.key].id
  route_table_id          = azurerm_route_table.example.id
}
# Create a storage account with a private endpoint
resource "azurerm_storage_account" "example" {
  name                     = "kevinstorageaccount1"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}
