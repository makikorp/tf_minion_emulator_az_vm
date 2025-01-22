output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

#output "public_ip_address_minion" {
output "public_ip_addresses" {
  value = tomap({for name, vm in azurerm_linux_virtual_machine.onms_minion_vm : name => vm.public_ip_address}) 
}
