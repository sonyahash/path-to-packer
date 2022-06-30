terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "0.17.0"
    }

  }
  required_version = ">= 0.14.5"

  cloud {
    organization = "path-to-packer"
    workspaces {
      tags = ["path-to-packer"]
    }
  }
}

provider "hcp" {}

data "hcp_packer_iteration" "ubuntu" {
  bucket_name = var.hcp_bucket_ubuntu
  channel     = var.hcp_channel
}

data "hcp_packer_image" "ubuntu" {
  bucket_name    = data.hcp_packer_iteration.ubuntu.bucket_name
  iteration_id   = data.hcp_packer_iteration.ubuntu.ulid
  cloud_provider = "aws"
  region         = var.region
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "path-to-packer_frontend" {
  ami                         = data.hcp_packer_image.ubuntu.cloud_image_id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_22_80_443.id]
  key_name                    = aws_key_pair.path-to-packer.key_name
  associate_public_ip_address = true
  user_data                   = templatefile("${path.module}/config.tftpl", {name = var.user_name})

  tags = {
    Name = "path-to-packer-frontend"
  }

  provisioner "file" {
    source = "./index.html"
    destination = "/tmp/index.html"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.path2packer.private_key_pem
      host        = aws_instance.path-to-packer_frontend.public_ip
    }
  }
}

resource "tls_private_key" "path2packer" {
  algorithm = "RSA"
}

locals {
  private_key_filename = "packer-ssh-key.pem"
}

resource "aws_key_pair" "path-to-packer" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.path2packer.public_key_openssh
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.cidr_subnet
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_security_group" "sg_22_80_443" {
  name   = "sg_22_80_443"
  vpc_id = aws_vpc.vpc.id

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "app_url" {
  value = "http://${aws_instance.path-to-packer_frontend.public_ip}"
}


