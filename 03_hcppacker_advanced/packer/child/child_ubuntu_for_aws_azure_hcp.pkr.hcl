packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_prefix" {
  type    = string
  default = "packer-intro-aws"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

data "hcp-packer-image" "packer-intro-ubuntu" {
  bucket_name    = "packer-intro-ubuntu"
  channel        = "prod"
  cloud_provider = "aws"
  region         = "ap-northeast-1"
}

source "amazon-ebs" "aws-ubuntu-tokyo" {
  ami_name      = "child-tokyo-${var.aws_prefix}-${local.timestamp}"
  source_ami    = data.hcp-packer-image.packer-intro-ubuntu.id
  instance_type = "t2.micro"
  #source_ami_filter {
  #  filters = {
  #    name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
  #    root-device-type    = "ebs"
  #    virtualization-type = "hvm"
  #  }
  #  most_recent = true
  #  owners      = ["099720109477"]
  #}
  tags = {
    env = "03_hcppacker_adv"
  }
  ssh_username = "ubuntu"
}

build {
  hcp_packer_registry {
    bucket_name = "packer-intro-ubuntu-child"
    description = <<EOT
はじめてのPackerシリーズ、子イメージ用のImage Bucketです。
  EOT
    bucket_labels = {
      owner = "taromurata"
      os    = "ubuntu"
      env   = "packer-intro"
      type  = "child"
    }
  }

  name = "packer_intro_aws_child"

  sources = [
    "source.amazon-ebs.aws-ubuntu-tokyo",
  ]

  provisioner "shell" {
    #environment_vars = [
    #  "FOO=hello world",
    #]
    #inline = [
    #  "echo Installing Redis",
    #  "sleep 30",
    #  "sudo apt-get update",
    #  "sudo apt-get install -y redis-server",
    #  "echo \"FOO is $FOO\" > example.txt",
    #]
    inline = [
      "sudo apt update && sudo apt install gpg",
      "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt update",
      "sudo apt install consul",
    ]
  }
}

