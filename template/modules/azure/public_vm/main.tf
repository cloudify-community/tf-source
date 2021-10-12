terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>2.0"
        }
    }
}

provider "azurerm" {
    features {}

    subscription_id   = var.subscription_id
    tenant_id         = var.tenant_id
    client_id         = var.client_id
    client_secret     = var.client_secret
}

resource "random_id" "suffix" {
    byte_length = 4
}

resource "azurerm_resource_group" "rg" {
    name        = "${var.prefix}-rg-${random_id.suffix.hex}"
    location    = var.region
}

resource "azurerm_virtual_network" "network" {
    name                = "${var.prefix}-net-${random_id.suffix.hex}"
    address_space       = ["10.0.0.0/23"]
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "subnet" {
    name                 = "${var.prefix}-subnet-${random_id.suffix.hex}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.network.name
    address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "fip" {
    name                = "${var.prefix}-ip-${random_id.suffix.hex}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "sg" {
    name                = "${var.prefix}-sg-${random_id.suffix.hex}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location

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

resource "azurerm_network_interface" "nic" {
    name                = "${var.prefix}-nic-${random_id.suffix.hex}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location

    ip_configuration {
        name                          = "${var.prefix}-niccfg-${random_id.suffix.hex}"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.fip.id
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic_assoc" {
    network_interface_id      = azurerm_network_interface.nic.id
    network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
    name                = "${var.prefix}-vm-${random_id.suffix.hex}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = "Standard_F2"
    admin_username      = "azureuser"

    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]

    admin_ssh_key {
        username   = "azureuser"
        public_key = var.admin_key_public
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = var.image.publisher
        offer     = var.image.offer
        sku       = var.image.sku
        version   = var.image.version
    }
}

output "public_ip" {
  value = azurerm_public_ip.fip.ip_address
}
