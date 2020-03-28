/*
* Deploying three Ubuntu Linux VM 18.04. They will be named
* <resource_prefix>node0-vm, <resource_prefix>node1-vm, <resource_prefix>node2-vm
* and install necessary package to run Kubernetes
*/


# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix}_rg"
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_prefix}-vnet"
  address_space       = [var.vnet_range]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "lan-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.lan_subnet
}

# Create Network Security Group and rules
# Allowing SSH for incoming connection for management
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.resource_prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  count               = 3
  name                = "${var.resource_prefix}node${count.index}-PublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  }

data "azurerm_public_ip" "publicip" {
  count               = 3
  name                = azurerm_public_ip.publicip[count.index].name
  resource_group_name = azurerm_resource_group.rg.name
}


# Create network interface
resource "azurerm_network_interface" "nic" {
  count                     = 3
  name                      = "${var.resource_prefix}node${count.index}-nic"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  network_security_group_id = azurerm_network_security_group.nsg.id

  ip_configuration {
    name                          = "${var.resource_prefix}node${count.index}-nicconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[count.index].id
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  count                 = 3
  name                  = "${var.resource_prefix}node${count.index}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  vm_size               = var.vm_size

  storage_os_disk {
    name              = "${var.resource_prefix}node${count.index}OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.ver
  }

  os_profile {
    computer_name  = "${var.resource_prefix}node${count.index}-vm"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


# Update and install the neccessary package to run Kubernetes
  provisioner "remote-exec" {
    connection {
      host     = azurerm_public_ip.publicip[count.index].ip_address
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install docker.io",
      "docker --version",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo apt-get -y install curl",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add",
      "sudo apt-add-repository \"deb http://apt.kubernetes.io/ kubernetes-xenial main\"",
      "sudo apt-get -y install kubeadm kubelet kubectl",
      "sudo apt-mark hold kubeadm kubelet kubectl",
      "kubeadm version",
      "sudo swapoff -a"
    ]
  }
}