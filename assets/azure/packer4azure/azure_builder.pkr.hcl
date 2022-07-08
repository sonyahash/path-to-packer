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
  subscription_id                   = "<subscription_id>"
  client_id                         = "<client_id>"
  client_secret                     = "<client_secret>"
  tenant_id                         = "<tenant_id>"
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "16.04-LTS"
  location                          = "Central US"
  managed_image_name                = "myPackerImage"
  managed_image_resource_group_name = "path-to-packer"
  os_type                           = "Linux"
  vm_size                           = "Standard_D2as_v5"
}

build {
  sources = ["source.azure-arm.ubuntu"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = ["apt-get update", "apt-get upgrade -y", "apt-get -y install nginx", "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
    inline_shebang  = "/bin/sh -x"
  }

  hcp_packer_registry {
    bucket_name = "path-to-packer-azure"
    description = "Path to Packer Demo on azure!"
    bucket_labels = {
      "Name"        = "path-to-packer-ubuntu-us-central"
      "Environment" = "Hashicorp Demo"
      "Developer"   = "Path to Packer Interns"
      "Owner"       = "Production"
      "OS"          = "Ubuntu"
      "Version"     = "Canonical 16.04"
    }

    build_labels = {
      "team"         = "SE Interns"
      "build-time"   = timestamp(),
      "build-source" = basename(path.cwd)
    }
  }

}