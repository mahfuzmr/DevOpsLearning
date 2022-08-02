
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "Azuredevops" {
   name =  "Azuredevops"
   location = "South Central US"
}


data "azurerm_platform_image" "ubunti1804LTS" {
  location  = azurerm_resource_group.Azuredevops.location
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
}

resource "azurerm_network_security_group" "Azuredevops" {
  name                = "Azuredevops-NSG"
  location            = "${azurerm_resource_group.Azuredevops.location}"
  resource_group_name = "${azurerm_resource_group.Azuredevops.name}"

  security_rule {
    name                       = "allow_SSHib"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
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
resource "azurerm_public_ip" "Azuredevops" {
  name                = "TestPublicIp1"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
    project= "project01"  
  }
}
resource "azurerm_network_interface" "Azuredevops" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = count.index == 1 ? azurerm_public_ip.Azuredevops.id : null
    
  }
}

resource "tls_private_key" "Azuredevops" {
  algorithm   = "RSA"
  rsa_bits    = 4096
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
admin_ssh_key {
    username   = "${var.username}"
    public_key = tls_private_key.Azuredevops.public_key_openssh
  }
 source_image_reference {
    publisher = data.azurerm_platform_image.ubunti1804LTS.publisher
    offer     = data.azurerm_platform_image.ubunti1804LTS.offer
    sku       = data.azurerm_platform_image.ubunti1804LTS.sku
    version   = data.azurerm_platform_image.ubunti1804LTS.version
  } 

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
   tags = {
    environment = "Production"
    project= "project01"
  }
}