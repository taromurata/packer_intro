terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.56.0"
    }
  }

  required_version = ">= 1.4.0"
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "hcp" {}

data "hcp_packer_image" "packer-intro-ubuntu" {
  bucket_name    = "packer-intro-ubuntu"
  channel        = "latest"
  cloud_provider = "aws"
  region         = "ap-northeast-1"
}

resource "aws_instance" "db_server" {
  #  ami           = "ami-072bfb8ae2c884cc4"
  ami           = data.hcp_packer_image.packer-intro-ubuntu.cloud_image_id
  instance_type = "t2.micro"

  tags = {
    Name = "Sample Instance by TF"
    Env  = "Demo"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-072bfb8ae2c884cc4"
  instance_type = "t2.micro"

  tags = {
    Name = "Sample Instance by TF"
    Env  = "Demo"
  }
}
