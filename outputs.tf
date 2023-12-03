output "vm_a_public_ip" {
  value = azurerm_windows_virtual_machine.vm_a.public_ip_address
}

output "vm_b_public_ip" {
  value = azurerm_windows_virtual_machine.vm_b.public_ip_address
}
