# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "onms_minion_vm" {
  for_each              = var.instances
  name                  = each.key
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic[each.key].id]
  size                  = "Standard_DS3_v2"

  os_disk {
    name                = "${each.key}_OsDisk"  
    #name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    #publisher = "erockyenterprisesoftwarefoundationinc1653071250513"
    publisher = "resf"
    #offer     = "rockylinux-9"
    offer      = "rockylinux-x86_64"
    sku       = "9-lvm"
    #sku       = "rockylinux-9"
    version   = "latest"
    #version   = "9.3.20231113"
  }

  plan {
    name = "9-lvm"
    product = "rockylinux-x86_64"
    publisher = "resf"
  }

  computer_name  = "${each.key}"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    #key = var.key_name
    public_key = file(var.public_key_path)

  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }

}

resource "local_file" "public_ip_address"{
  for_each = var.instances
  content = "[main]\n${azurerm_linux_virtual_machine.onms_minion_vm[each.key].public_ip_address}"
  filename = "azure_hosts"
}


#Call and run Ansible playbook
resource "null_resource" "opennms_install" {
  
  provisioner "local-exec" {
    command = "ansible-playbook -i /path/to/code/tf_minion_emulator_az_vm/azure_hosts --key-file /path/to/.ssh/<key_name> playbooks/minion.yml"
  }
  depends_on = [
    azurerm_linux_virtual_machine.onms_minion_vm
  ]

}





