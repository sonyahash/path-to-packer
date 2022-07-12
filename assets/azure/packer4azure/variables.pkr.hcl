variable "subscription_id" {
  type    = string
  default = "<SUBSCRIPTION_ID>"
}

variable "client_id" {
  type    = string
  default = "<CLIENT_ID>"
}

variable "client_secret" {
  type    = string
  default = "<CLIENT_SECRET>"
}

variable "tenant_id" {
  type    = string
  default = "<TENANT_ID>"
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
    "Name"        = "path-to-packer-ubuntu-us-central"
    "Environment" = "HashiCorp Demo"
    "Developer"   = "Path to Packer Interns"
    "OS"          = "Ubuntu"
    "Version"     = "Canonical 16.04"
  }
}