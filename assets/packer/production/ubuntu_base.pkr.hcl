packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
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

build {
    hcp_packer_registry {
    bucket_name   = "path-to-packer-frontend-ubuntu"
    description   = "Path to Packer Demo"
    bucket_labels = var.aws_tags
    build_labels = {
      "build-time"   = timestamp(),
      "build-source" = basename(path.cwd)
    }
  }

  sources = [
    "source.amazon-ebs.ubuntu-server-east"
  ]

  # Add startup script that will run path to packer on instance boot
  provisioner "file" {
    source      = "../production/setup-deps-path-to-packer.sh"
    destination = "/tmp/setup-deps-path-to-packer.sh"
  }

  # Move temp files to actual destination
  # Must use this method because their destinations are protected
  provisioner "shell" {
    inline = [
      "sudo cp /tmp/setup-deps-path-to-packer.sh /var/lib/cloud/scripts/per-boot/setup-deps-path-to-packer.sh",
    ]
  }

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