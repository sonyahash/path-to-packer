##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)
variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  default = "<YOUR_NAME>"
}

variable "client_id" {
  description = "This is the client id that the azure cli will provide you with."
  default = "<CLIENT_ID>"
}

variable "tenant_id" {
  description = "This is the tenant id that the azure cli will provide you with."
  default = "<TENANT_ID>"
}

variable "client_secret" {
  description = "This is the client secret that the azure cli will provide you with."
  default = "<CLIENT_SECRET>"
}

variable "subscription_id" {
  description = "This is the subscription id that the azure cli will provide you with."
  default = "<SUBSCRIPTION_ID>"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "centralus"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_DS1_V2"
}

variable "admin_username" {
  description = "Administrator user name for linux and mysql"
  default     = "hashicorp"
}

variable "admin_password" {
  description = "Administrator password for linux and mysql"
  default     = "Password123!"
}