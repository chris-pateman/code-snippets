resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.vm_name}-ip"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_network_interface_backend_address_pool_association" "be_pool_aso" {
  network_interface_id    = azurerm_network_interface.vm_nic.id
  ip_configuration_name   = "${var.vm_name}-ip"
  backend_address_pool_id = var.backend_pool_id
}

resource "azurerm_network_interface_security_group_association" "vm_nic_sg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  availability_set_id = var.availability_set_id

  os_disk {
    name                 = "${var.vm_name}-OS"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = var.vm_storage_image_reference.publisher
    offer     = var.vm_storage_image_reference.offer
    sku       = var.vm_storage_image_reference.sku
    version   = var.vm_storage_image_reference.version
  }
}
