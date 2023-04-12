terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.4.0"
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "db_server" {
  ami           = "ami-072bfb8ae2c884cc4"
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
