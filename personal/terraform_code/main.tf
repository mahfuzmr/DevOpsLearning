
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "Azuredevops" {
   name =  "Azuredevops"
   location = "South Central US"
   tags = {
    environment = "Production"
    project= "project01"
  }
}


data "azurerm_platform_image" "ubunti1804LTS" {
  location  = azurerm_resource_group.Azuredevops.location
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
}

resource "azurerm_virtual_network" "Azuredevops" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Azuredevops.location
  resource_group_name = azurerm_resource_group.Azuredevops.name
  tags = {
    environment = "Production"
    project= "project01"
  }
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

resource "azurerm_lb" "vm_lb" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.Azuredevops.location
  resource_group_name = "${azurerm_resource_group.Azuredevops.name}"

  frontend_ip_configuration {
    name                 = "FrontAddressPool"
    public_ip_address_id = azurerm_public_ip.Azuredevops.id
  }
    tags = {
    environment = "Production"
    project= "project01"  
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 loadbalancer_id     = azurerm_lb.vm_lb.id
 name                = "BackEndAddressPool"
}

resource "azurerm_network_security_group" "Azuredevops" {
  name                = "Azuredevops-NSG"
  location            = "${azurerm_resource_group.Azuredevops.location}"
  resource_group_name = "${azurerm_resource_group.Azuredevops.name}"  

  tags = {
    environment = "Production"
    project= "project01"  
  }
}
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                 = "nic-${count.index}"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location
  

  ip_configuration {
    name                          = "nic-${count.index}"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
   
  }
  tags = {
    environment = "Production"
    project= "project01"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_bapa" {
  count                   = var.vm_count  
  ip_configuration_name   = "nic-${count.index}"
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.bpepool.id}"
}

resource "tls_private_key" "Azuredevops" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "azurerm_availability_set" "abilityset" {
  name                = "${var.prefix}-abset"
  location            = azurerm_resource_group.Azuredevops.location
  resource_group_name = azurerm_resource_group.Azuredevops.name
  platform_fault_domain_count = 3
  platform_update_domain_count = 3  
  depends_on = [
    azurerm_resource_group.Azuredevops
  ]

  tags = {
    environment = "Production"
    project= "project01"
  }
}


resource "azurerm_linux_virtual_machine" "Azuredevops" {
  count                           = var.vm_count 
  name                            = "${var.prefix}-${count.index}-vm"
  resource_group_name             = azurerm_resource_group.Azuredevops.name
  location                        = azurerm_resource_group.Azuredevops.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  availability_set_id             = azurerm_availability_set.abilityset.id 
  network_interface_ids           = [element(azurerm_network_interface.nic.*.id, count.index)]


  disable_password_authentication = false


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
output "ip-addres" {
      description = "The Public IP address is:"
      value = azurerm_public_ip.Azuredevops.id
       }
output "vm-name" {     
      description = "The VM name is:"
      value = "${var.prefix}-${var.vm_count}-vm"
       }