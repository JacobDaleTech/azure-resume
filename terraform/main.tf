resource "azurerm_resource_group" "resourcegroup_azureresume" {
  location   = "eastus"
  name       = "rg_azureresume"
  tags       = {}
}

resource "azurerm_user_assigned_identity" "managedidentity_uami2" {
  location            = "eastus2"
  name                = "pyresumecounter-id-8ac3"
  resource_group_name = "rg_azureresume"
  tags                = {}
}

resource "azurerm_user_assigned_identity" "managedidentity_uami" {
  location            = "eastus2"
  name                = "pyresumecounter-uami"
  resource_group_name = "rg_azureresume"
  tags                = {}
}

resource "azurerm_monitor_action_group" "actiongroup_functionapp" {
  enabled             = true
  location            = "global"
  name                = "Application Insights Smart Detection"
  resource_group_name = "rg_azureresume"
  short_name          = "SmartDetect"
  tags                = {}

  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }

  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }
}

resource "azurerm_cosmosdb_account" "cosmosdb_azureresume" {
  name                              = "jditazureresume"
  location                          = "eastus"
  resource_group_name               = "rg_azureresume"
  offer_type                        = "Standard"
  kind                              = "GlobalDocumentDB"
  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
  geo_location {
    location          = "eastus"
    failover_priority = 0
    zone_redundant    = false
  }
  capabilities {
    name = "EnableServerless"
  }
  capacity {
    total_throughput_limit = 4000
  }
  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 8
    storage_redundancy  = "Geo"
  }
  analytical_storage {
    schema_type = "WellDefined"
  }
  minimal_tls_version = "Tls12"
  tags = {
    defaultExperience       = "Core (SQL)"
    hidden-cosmos-mmspecial = ""
    hidden-workload-type    = "Learning"
  }
}

resource "azurerm_service_plan" "asp_functionapp" {
  name                = "ASP-rgazureresume-8905"
  location            = "eastus2"
  resource_group_name = "rg_azureresume"
  os_type             = "Linux"
  sku_name            = "FC1"
  tags                = {}
}

resource "azurerm_storage_account" "storageaccount_functionapp" {
  name                     = "rgazureresumeb88b"
  location                 = "eastus2"
  resource_group_name      = "rg_azureresume"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    change_feed_enabled           = false
    change_feed_retention_in_days = 7
    versioning_enabled            = false
  }

  tags = {}
}

resource "azurerm_storage_account" "storageaccount_azureresume" {
  name                     = "jacobdaleazureresume"
  location                 = "eastus"
  resource_group_name      = "rg_azureresume"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"

  blob_properties {
    change_feed_enabled           = false
    change_feed_retention_in_days = 7
    versioning_enabled            = false
  }

  custom_domain {
    name          = "www.jditprojects.com"
    use_subdomain = false
  }

  tags = {}
}

resource "azurerm_application_insights" "appinsights_functionapp" {
  name                = "pyresumecounter"
  location            = "eastus2"
  resource_group_name = "rg_azureresume"
  application_type    = "web"
  retention_in_days   = 90
  daily_data_cap_in_gb = 100
  tags = {}
  workspace_id = "/subscriptions/83f82310-d306-4946-b195-dd8b98f4b1f8/resourceGroups/DefaultResourceGroup-EUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-83f82310-d306-4946-b195-dd8b98f4b1f8-EUS2"
}

resource "azurerm_function_app_flex_consumption" "functionapp_azureresume" {
  name                = "pyresumecounter"
  location            = "eastus2"
  resource_group_name = "rg_azureresume"
  service_plan_id     = azurerm_service_plan.asp_functionapp.id
  runtime_name        = "python"
  runtime_version     = "3.12"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managedidentity_uami.id]
  }

  app_settings = {
    COSMOS_DB_URI     = "https://jditazureresume.documents.azure.com:443/"
    COSMOS_DB_KEY     = "<REDACTED>"
    COSMOS_DB_NAME    = "AzureResume"
    COSMOS_DB_CONTAINER = "Counter"
    AzureWebJobsStorage__blobServiceUri  = "https://rgazureresumeb88b.blob.core.windows.net"
    AzureWebJobsStorage__queueServiceUri = "https://rgazureresumeb88b.queue.core.windows.net"
    AzureWebJobsStorage__tableServiceUri = "https://rgazureresumeb88b.table.core.windows.net"
    AzureWebJobsStorage__clientId        = azurerm_user_assigned_identity.managedidentity_uami.client_id
    AzureWebJobsStorage__credential      = "managedidentity"
  }

  storage_container_type             = "blobContainer"
  storage_container_endpoint         = "https://rgazureresumeb88b.blob.core.windows.net/app-package-pyresumecounter-33a6eba"
  storage_user_assigned_identity_id  = azurerm_user_assigned_identity.managedidentity_uami.id
  storage_authentication_type        = "UserAssignedIdentity"

  site_config {
    health_check_path                  = "/"
    health_check_eviction_time_in_min = 2
    minimum_tls_version                = "1.2"
    load_balancing_mode                = "LeastRequests"
    managed_pipeline_mode              = "Integrated"
    use_32_bit_worker                  = false
    cors {
      allowed_origins     = ["https://portal.azure.com", "https://www.jditprojects.com"]
      support_credentials = false
    }
  }

  tags = {}
}
