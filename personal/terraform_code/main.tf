
provider "azurerm" {
  features {}
}

#in Udacity lab resource group is already available
#resource "azurerm_resource_group" "Azuredevops" {
 # name     = "${var.prefix}-resources"
  #location = var.location
#}
resource "azurerm_resource_group" "Azuredevops" {
   name =  "Azuredevops"
   location = "East US"
}

resource "azurerm_virtual_network" "Azuredevops" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.Azuredevops.location
  resource_group_name = azurerm_resource_group.Azuredevops.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.Azuredevops.name
  virtual_network_name = azurerm_virtual_network.Azuredevops.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "Azuredevops" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "Azuredevops" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.Azuredevops.name
  location                        = azurerm_resource_group.Azuredevops.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.Azuredevops.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}