packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
    azure = {
      version = ">= 1.4.1"
      source = "github.com/hashicorp/azure"
    }
  }
}

variable "aws_prefix" {
  type    = string
  default = "packer-intro-aws"
}

variable "azure_prefix" {
  type = string
  default = "packer-intro-azure"
}

variable "azure_resource_group" {
  type = string
  default = "packer_intro_rg"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "aws-ubuntu-tokyo" {
  ami_name      = "tokyo-${var.aws_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-northeast-1" // 東京
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
    env = "packer_intro"
  }
  ssh_username = "ubuntu"
}

source "amazon-ebs" "aws-ubuntu-osaka" {
  ami_name      = "osaka-${var.aws_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-northeast-3" // 大阪
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
    env = "packer_intro"
  }
  ssh_username = "ubuntu"
}

source "azure-arm" "azure-ubuntu-tokyo" {
  managed_image_resource_group_name = var.azure_resource_group
  managed_image_name = "tokyo-${var.azure_prefix}-${local.timestamp}"

  use_azure_cli_auth = true

  os_type = "Linux"
  image_publisher = "Canonical"
  image_offer = "0001-com-ubuntu-server-focal"
  image_sku = "20_04-lts"

  azure_tags = {
    demo = "packer_intro"
  }

  location = "Japan East" // 東京
  vm_size = "Standard_A2"
}

build {
  # 変更箇所
  hcp_packer_registry {
    bucket_name = "packer-intro_ubuntu"
    description = <<EOT
はじめてのPackerシリーズ用のImage Bucketです。
  EOT
    bucket_labels = {
      owner = "taromurata"
      os    = "ubuntu"
      env   = "packer-intro"
    }
  }
  # --------
  name    = "packer_intro_2aws_1azure"

  sources = [
    "source.amazon-ebs.aws-ubuntu-tokyo",
    "source.amazon-ebs.aws-ubuntu-osaka",
    "source.azure-arm.azure-ubuntu-tokyo",
  ]

  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      "echo Installing Redis",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y redis-server",
      "echo \"FOO is $FOO\" > example.txt",
    ]
  }

  provisioner "shell" {
    inline = ["echo This provisioner runs last"]
  }

  #post-processors {
  #  post-processor "vagrant" {
  #    keep_input_artifact = true
  #  }
  #}
}

