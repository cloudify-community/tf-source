# OpenStack Application Credentials (Keystone v3)
# https://docs.openstack.org/keystone/latest/user/application_credentials.html
variable "credentials" {
  description = "OpenStack Application Credential (v3)"
  type = object({
    application_id = string
    application_secret = string
  })
}

variable "auth_url" { 
  type = string
  description = "OpenStack Identity (v3) authentication endpoint. Example: https://example.com:13000/v3/"
}

variable "region" {
  type = string
  description = "OpenStack region to create resources in"
}

variable "auth_url_insecure" {
    type = bool
    description = "Skip TLS validation on the authentication endpoint."
}

variable "admin_user" {
  type = string
  description = "Admin user for the image we're launching"
}

variable "admin_key_public" {
  type = string
  description = "Public SSH key of admin user"
}

variable "external_network_name" { 
  type = string
  description = "External network name to use. `openstack network list --external`"
}

variable "flavor" {
  type = string
  description = "Compute flavor name to use. `openstack flavor list`"
}

variable "image" {
  type = string
  description = "Glance image name to use. `openstack image list`"
}

variable "root_disk_size" {
  type = number
  description = "Size of the root volume in GB"
  default = 20
}

variable "prefix" {
  type = string
  description = "Resource name prefix"
  default = "cfy"
}
