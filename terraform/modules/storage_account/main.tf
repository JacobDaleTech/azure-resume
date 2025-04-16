resource "azurerm_storage_account" "jacobdaleresume" {
  name                     = "jacobdaleresume"
  resource_group_name      = azurerm_resource_group.rg-azureresume.name
  location                 = azurerm_resource_group.rg-azureresume.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_account_static_website" "test" {
  storage_account_id = azurerm_storage_account.test.id
  error_404_document = "custom_not_found.html"
  index_document     = "custom_index.html"
}