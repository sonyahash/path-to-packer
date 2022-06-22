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

  ## HashiCups
  # Add startup script that will run path to packer on instance boot
  provisioner "file" {
    source      = "setup-deps-path-to-packer.sh"
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
   "sudo amazon-linux-extras enable nginx1.12",
   "sudo yum -y install nginx",
   "sudo systemctl start nginx"
  ]
 }

  #provisioner "shell" {
  # inline = [
  #   # use nginx=development for latest development version
  #    "sudo -s",
  #    "nginx=stable",
  #    "add-apt-repository ppa:nginx/$nginx",
  #    "apt update",
  #    "apt install nginx",
  #    "sudo systemctl status nginx",
  #    "sudo systemctl start nginx",
  #    "sudo systemctl enable nginx",
  #
  #    #Allow NGINX traffic and grant access to the firewall
  #    "sudo ufw app list",
  #    "sudo ufw allow 'nginx full'",
  #    "sudo ufw reload"
  #  ]
  # }

  # provisioner "shell" {
  #   inline = [
  #     "echo '***** Running CIS LTS Benchmark tests'",
  #     "echo '1.1.1.3 Ensure mounting of jffs2 filesystems is disabled'",
  #     "modprobe -n -v jffs2 | grep -E '(jffs2|install)'"
  #   ]
  # }
}
