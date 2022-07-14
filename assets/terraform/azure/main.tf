terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }

  required_version = ">= 0.14.5"

  cloud {
    organization = "<ORG_NAME>"
    workspaces {
      name = "path-to-packer-azure"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

# Locate the existing resource group
data "azurerm_resource_group" "main" {
  name = "path-to-packer"
}

output "id" {
  value = data.azurerm_resource_group.main.id
}

# Locate the existing custom image
data "azurerm_image" "main" {
  name                = "myPackerImage"
  resource_group_name = "path-to-packer"
}

output "image_id" {
  value = "/subscriptions/${var.subscription_id}/resourceGroups/RG-EASTUS-SPT-PLATFORM/providers/Microsoft.Compute/images/myPackerImage"
}

# Create a new Virtual Machine based on the custom Image
resource "azurerm_virtual_machine" "myVM" {
  name                             = "myVM"
  location                         = var.location
  resource_group_name              = data.azurerm_resource_group.main.name
  network_interface_ids            = ["${azurerm_network_interface.main.id}"]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id        = "${data.azurerm_image.main.id}"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.prefix
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "Production"
  }

  provisioner "file" {
    source      = "./index.html"
    destination = "/tmp/index.html"
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.main.fqdn
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cd /etc/nginx/sites-enabled",
      "sudo unlink default",
      "sudo cd ../",
      "sudo cd /var/www/",
      "sudo mv /tmp/index.html /var/www/html/",
      "sudo systemctl reload nginx"
    ]
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.main.fqdn
    }
  }
}

# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
}

# Create subnet
resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_prefix]
}

# Create public IP
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-ip"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  domain_name_label   = "path-to-packer-${var.prefix}"
}

# Create network interface
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-sg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  
}

output "your_app_url" {
    value = "http://${azurerm_public_ip.main.fqdn}"
}
