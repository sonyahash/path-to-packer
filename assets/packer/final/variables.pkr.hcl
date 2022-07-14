#####################################################
# These are the AWS Specific Variables
#####################################################

variable "region" {
  type    = string
  default = "us-east-2"
}

# This is the version release for this AMI
variable "version" {
  type    = string
  default = "1.0.0"
}

# Canonical publishes Ubuntu images to support numerous features found on EC2.
# https://ubuntu.com/server/docs/cloud-images/amazon-ec2
# The Canonical ID is "099720109477" and we use that in our build section.
# To obtain the whole list of Ubuntu images available use:
# aws ec2 describe-images --owners 099720109477
# But, use filters to make your life a bit easier.

variable "image_name" {
  type    = string
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

# These are meta-data to support document your AMI.

variable "aws_tags" {
  type = map(string)
  default = {
    "Name"        = "path-to-packer-ubuntu-us-east-2"
    "Environment" = "Hashicorp Demo"
    "Developer"   = "Path to Packer Interns"
    "Owner"       = "Production"
    "OS"          = "Ubuntu"
    "Version"     = "Focal 20.04"
  }
}

#####################################################
# These are the Azure Specific Variables
#####################################################

variable "client_id" {
  type    = string
  default = "<CLIENT_ID>"
}

variable "tenant_id" {
  type    = string
  default = "<TENANT_ID>"
}

variable "client_secret" {
  type    = string
  default = "<CLIENT_SECRET>"
}
variable "subscription_id" {
  type    = string
  default = "<SUBSCRIPTION_ID>"
}

variable "location" {
  type    = string
  default = "centralus"
}

variable "vm_size" {
  type    = string
  default = "Standard_DS1_V2"
}

variable "azure_tags" {
  type = map(string)
  default = {
    "Name"        = "path-to-packer"
    "Environment" = "HashiCorp Demo"
    "Developer"   = "Path to Packer Interns"
    "OS"          = "Ubuntu"
    "Version"     = "Canonical 16.04"
  }
}