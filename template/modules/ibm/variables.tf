variable "ibmcloud_api_key" {
  type = string
  description = "IBM Cloud API key"
}

variable "region" {
  type = string
  description = "Region to launch servers."
}

variable "admin_key_public" {
  type = string
  description = "Public SSH key of admin user"
}

variable "image" {
  type = string
  description = "Image name"
}
variable "prefix" {
  type = string
  description = "Resource name prefix"
  default = "cfy"
}

