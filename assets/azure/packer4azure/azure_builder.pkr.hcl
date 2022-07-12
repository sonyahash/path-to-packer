packer {
  required_plugins {
    azure = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/azure"
    }
  }
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
  sources = ["source.azure-arm.ubuntu"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = [
                        "sudo apt-get update",
                        "sudo apt-get upgrade -y", 
                        "sudo apt-get -y install nginx", 
                        "sudo /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang  = "/bin/sh -x"
  }

  hcp_packer_registry {
    bucket_name = "path-to-packer-azure"
    description = "Path to Packer Demo on Azure!"
    bucket_labels = var.azure_tags
    build_labels = {
      "team"         = "SE Interns"
      "build-time"   = timestamp(),
      "build-source" = basename(path.cwd)
    }
  }
  
}