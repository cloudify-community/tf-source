terraform {
    required_providers {
        ibm = {
        source = "IBM-Cloud/ibm"
        version = "~>1.38.1"
        }
    }
}

provider "ibm" {
    ibmcloud_api_key   = var.ibmcloud_api_key
    region = var.region
}

resource "random_id" "suffix" {
    byte_length = 4
}

resource "ibm_is_vpc" "iac_test_vpc" {
  name = "${var.prefix}-vpc-${random_id.suffix.hex}"
}

resource "ibm_is_subnet" "iac_test_subnet" {
  name            = "${var.prefix}-subnet-${random_id.suffix.hex}"
  vpc             = ibm_is_vpc.iac_test_vpc.id
  zone            = "${var.region}-1"

  ipv4_cidr_block = "10.243.0.0/24"
}

resource "ibm_is_ssh_key" "testacc_sshkey" {
  name       = "${var.prefix}-key-${random_id.suffix.hex}"
  public_key = var.admin_key_public
}

data "ibm_is_image" "ds_image" {
  name = var.image
}

resource "ibm_is_instance" "testacc_instance" {
  name    = "${var.prefix}-vm-${random_id.suffix.hex}"
  image   = data.ibm_is_image.ds_image.id
  profile = "bx2d-2x8"

  primary_network_interface {
    subnet = ibm_is_subnet.iac_test_subnet.id
  }

  network_interfaces {
    name   = "eth1"
    subnet = ibm_is_subnet.iac_test_subnet.id
  }

  vpc  = ibm_is_vpc.iac_test_vpc.id
  zone = "${var.region}-1"
  keys = [ibm_is_ssh_key.testacc_sshkey.id]

  //User can configure timeouts
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

