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
  subscription_id                   = "da6df7d8-bf6a-46e2-b9e3-773f233c22b1"
  client_id                         = "216c39bd-b1c5-45aa-b3b1-b1b30e2a0bee"
  client_secret                     = "aNF8Q~QiycLJgNCcul5lJconHH8VQtPwwhHW6bi4"
  tenant_id                         = "3b0ec5e4-3007-4b1a-97d1-2a0d47d67b9f"
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