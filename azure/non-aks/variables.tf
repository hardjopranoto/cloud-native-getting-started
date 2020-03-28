# Defining the variables for admin_username and admin_password for the VM
# You may change this to your own admin username and password
# Resource prefix name will be prompted during run time

# The admin username and password of the linux host
variable "admin_username" {
  type = string
  default = "k8sadmin"
}

variable "admin_password" {
  type = string
  default = "C0mpl3xPa55w0rd!"
}

# The resource prefix of the k8s cluster
variable "resource_prefix" {
  type = string
  default = "testk8s"
}

# The azure region where you want to deploy the vm. 
# Change it to your local azure region
variable "location" {
  default = "australiaeast"
}

# The vnet address of the k8s cluster. 
# It must not overlap with any of your existing vnets in your azure subscription
variable "vnet_range" {
  type = string
  default = "10.13.0.0/16"
}

variable "lan_subnet" {
  type = string
  default = "10.13.1.0/24"
}

variable "vm_size" {
  type = string
  default = "Standard_DS2_v2"
}

# We're using Ubuntu 18.04 Linux as the VM image
variable "publisher" {
  type = string
  default = "Canonical"
}

variable "offer" {
  type = string
  default = "UbuntuServer"
}

variable "sku" {
  type = string
  default = "18_04-lts-gen2"
}

variable "ver" {
  type = string
  default = "latest"
}