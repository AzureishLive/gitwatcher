terraform {
  backend "azurerm" {}
}

locals {
  env_prefix = "${var.shortcode}-${var.product}-${var.envname}-${var.location_short_code}"
  env_prefix_no_separator = "${var.shortcode}${var.product}${var.envname}${var.location_short_code}"
}

resource "azurerm_resource_group" "rg" {
  name  = "${local.env_prefix}-rg"
  location = var.location

  tags = {
      product = var.product
  }
}

resource "azurerm_storage_account" "func_storage" {
  name                     = "${local.env_prefix_no_separator}sa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "func_plan" {
  name                = "${local.env_prefix}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "func_app" {
  name                       = "${local.env_prefix}-func"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key
}