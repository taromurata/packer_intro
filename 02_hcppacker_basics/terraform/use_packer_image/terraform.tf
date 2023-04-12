terraform {
  cloud {
    organization = "tarohcp"

    workspaces {
      name = "hcppacker-intro"
    }
  }
}
