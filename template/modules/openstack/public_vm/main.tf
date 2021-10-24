terraform {
    required_providers {
        openstack = {
            source = "terraform-provider-openstack/openstack"
            version = "~> 1.35.0"
        }
    }
}

provider "openstack" {
    auth_url = var.auth_url
    application_credential_id = var.credentials.application_id
    application_credential_secret = var.credentials.application_secret
    region = var.region
    insecure = var.auth_url_insecure
}

resource "random_id" "suffix" {
    byte_length = 4
}

data "openstack_networking_network_v2" "fippool" {
  name      = var.external_network_name
  external  = true
}

data "openstack_images_image_v2" "image" {
  name          = var.image
  most_recent   = true
}

resource "openstack_networking_network_v2" "network" {
  name           = "${var.prefix}-network-${random_id.suffix.hex}"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "${var.prefix}-subnet-${random_id.suffix.hex}"
  network_id = openstack_networking_network_v2.network.id
  cidr       = "192.168.100.0/24"
  ip_version = 4
}

resource "openstack_networking_router_v2" "router" {
  name                = "${var.prefix}-router-${random_id.suffix.hex}"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.fippool.id
}

# Attach the Router to the Network
resource "openstack_networking_router_interface_v2" "router_iface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

resource "openstack_networking_floatingip_v2" "public_ip" {
  pool = data.openstack_networking_network_v2.fippool.name
}

resource "openstack_compute_secgroup_v2" "sg" {
  name        = "${var.prefix}-sg-${random_id.suffix.hex}"
  description = "SG for Cloudify ${random_id.suffix.hex} run"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_keypair_v2" "kp" {
  name       = "${var.prefix}-kp-${random_id.suffix.hex}"
  public_key = var.admin_key_public
}

resource "openstack_blockstorage_volume_v3" "volume" {
  name        = "${var.prefix}-vm-${random_id.suffix.hex}-root"
  size        = max(var.root_disk_size, data.openstack_images_image_v2.image.min_disk_gb)
  image_id    = data.openstack_images_image_v2.image.id
}

resource "openstack_compute_instance_v2" "vm" {
  name            = "${var.prefix}-vm-${random_id.suffix.hex}"
  flavor_name     = var.flavor
  key_pair        = openstack_compute_keypair_v2.kp.name
  security_groups = ["default", openstack_compute_secgroup_v2.sg.name]

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.volume.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    uuid = openstack_networking_network_v2.network.id
  }
}

resource "openstack_compute_floatingip_associate_v2" "public_ip" {
  floating_ip = openstack_networking_floatingip_v2.public_ip.address
  instance_id = openstack_compute_instance_v2.vm.id
}

output "public_ip" {
  value = openstack_networking_floatingip_v2.public_ip.address
}
