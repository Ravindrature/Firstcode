provider "azurerm" {
  features = {}
}

resource "azurerm_resource_group" "rg_westus" {
  name     = "RG-WestUS"
  location = "westus"
}

resource "azurerm_resource_group" "rg_eastus" {
  name     = "RG-EastUS"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet_a" {
  name                = "VnetA"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.rg_westus.location
  resource_group_name = azurerm_resource_group.rg_westus.name
}

resource "azurerm_subnet" "subnet_a" {
  name                 = "SubnetA"
  resource_group_name  = azurerm_resource_group.rg_westus.name
  virtual_network_name = azurerm_virtual_network.vnet_a.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_virtual_network" "vnet_b" {
  name                = "VnetB"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg_eastus.location
  resource_group_name = azurerm_resource_group.rg_eastus.name
}

resource "azurerm_subnet" "subnet_b" {
  name                 = "SubnetB"
  resource_group_name  = azurerm_resource_group.rg_eastus.name
  virtual_network_name = azurerm_virtual_network.vnet_b.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_interface" "nic_a" {
  name                = "NIC-A"
  location            = azurerm_resource_group.rg_westus.location
  resource_group_name = azurerm_resource_group.rg_westus.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet_a.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_b" {
  name                = "NIC-B"
  location            = azurerm_resource_group.rg_eastus.location
  resource_group_name = azurerm_resource_group.rg_eastus.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet_b.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm_a" {
  name                  = "VM-A"
  resource_group_name   = azurerm_resource_group.rg_westus.name
  location              = azurerm_resource_group.rg_westus.location
  size                  = "Standard_DS2_v2"
  admin_username        = "ravinadmin"
  admin_password        = "Ravin@2023!"
  network_interface_ids = [azurerm_network_interface.nic_a.id]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "vm_b" {
  name                  = "VM-B"
  resource_group_name   = azurerm_resource_group.rg_eastus.name
  location              = azurerm_resource_group.rg_eastus.location
  size                  = "Standard_DS2_v2"
  admin_username        = "ravinadmin"
  admin_password        = "Ravin@2023!"
  network_interface_ids = [azurerm_network_interface.nic_b.id]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_network_peering" "peering" {
  name                         = "VnetAtoVnetB"
  resource_group_name          = azurerm_resource_group.rg_westus.name
  virtual_network_name         = azurerm_virtual_network.vnet_a.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_b.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "peering_reverse" {
  name                         = "VnetBtoVnetA"
  resource_group_name          = azurerm_resource_group.rg_eastus.name
  virtual_network_name         = azurerm_virtual_network.vnet_b.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_a.id
  allow_virtual_network_access = true
}
