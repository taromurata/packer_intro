terraform {
  cloud {
    organization = "tarohcp"

    workspaces {
      name = "packer_image_azure_resourcegroup"
    }
  }
}
