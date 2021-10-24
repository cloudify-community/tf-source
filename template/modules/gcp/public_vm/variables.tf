# jq -c . /path/to/gce-creds.json
variable "credentials_json" {
  type = string
  description = "Contents of a GCP JSON credentials file"
}

variable "project" { 
  type = string
  description = "GCP project ID"
}

# variable "region" {
#   type = string
#   description = "Region to launch servers"
# }

variable "zone" {
  type = string
  description = "Zone to launch servers"
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
    project = string
    family = string
  })
  default = {
    project = "ubuntu-os-cloud"
    family = "ubuntu-1804-lts"
  }
}

variable "prefix" {
  type = string
  description = "Resource name prefix"
  default = "cfy"
}
