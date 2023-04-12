terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.45.0"
    }
  }

  required_version = ">= 1.4.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "packer_intro" {
  name     = var.resource_group_name
  location = var.azure_location
}

