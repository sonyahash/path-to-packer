packer {
  required_plugins {
    azure = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/azure"
    }
  }
}

data "amazon-ami" "ubuntu-server-east" {
  region = var.region
  filters = {
    name                = var.image_name
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "ubuntu-server-east" {
  region         = var.region
  source_ami     = data.amazon-ami.ubuntu-server-east.id
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "path-to-packer{{timestamp}}_v${var.version}"
  tags           = var.aws_tags
}

source "azure-arm" "ubuntu" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  subscription_id                   = var.subscription_id
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  tenant_id                         = var.tenant_id
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "16.04-LTS"
  location                          = var.location
  managed_image_name                = "myPackerImage"
  managed_image_resource_group_name = "path-to-packer"
  os_type                           = "Linux"
  vm_size                           = var.vm_size
}

build {
  hcp_packer_registry {
    bucket_name = "path-to-packer"
    description = "Path to Packer Demo on Azure!"
    bucket_labels = var.azure_tags
    build_labels = {
      "team"         = "SE Interns"
      "build-time"   = timestamp(),
      "build-source" = basename(path.cwd)
    }
  }

  sources = [
    "source.azure-arm.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx",
      "sudo apt-get install tree"
    ]
  }
  
}