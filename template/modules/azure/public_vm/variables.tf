variable "region" {
  type = string
  description = "Region to launch servers."
}

variable "admin_user" {
  type = string
  description = "Admin user for the image we're launching"
}

variable "admin_key_public" {
  type = string
  description = "Public SSH key of admin user"
}

variable "image" {
  type = object({
    publisher = string
    offer = string
    sku = string
    version = string
  })
  default = {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }
}

variable "subscription_id" {
  type = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type = string
  description = "Azure Tenant ID"
}

variable "client_id" {
  type = string
  description = "Azure client (application) ID"
}

variable "client_secret" {
  type = string
  description = "Azure client (application) secret"
}

variable "prefix" {
  type = string
  description = "Resource name prefix"
  default = "cfy"
}
