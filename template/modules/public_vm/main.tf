# Specify the provider and access details
provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "vpc" {
  source = "../../"
  
  admin_user = var.admin_user
  aws_zone = var.aws_zone
  aws_region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
  admin_key_public = var.admin_key_public
}

data "aws_ami" "centos" {
owners      = ["125523088429"]
most_recent = true

  filter {
      name   = "name"
      values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }
}

resource "aws_instance" "example_vm" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = var.admin_user
  }

  instance_type = "t2.micro"

  tags = {
    Name = "cloudify-public-${var.env_name}-vm"
  }

  # Lookup the correct AMI based on the region
  # we specified
  ami = data.aws_ami.centos.id

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = module.vpc.group_ids

  # Connect to subnet
  subnet_id = module.vpc.subnet_id

  user_data =   data.template_file.template.rendered
}

resource "aws_eip" "eip" {
  instance = aws_instance.example_vm.id
  vpc      = true
}

variable "filename" {
  default = "cloud-config.cfg"
}

data "template_file" "template" {
  template = <<EOF
#cloud-config
users:
  - name: $${admin_user}
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - $${admin_key_public}
EOF
  vars = {
    admin_user = var.admin_user
    admin_key_public = var.admin_key_public
  }
}

output "ip" {
  value = aws_eip.eip.public_ip
}
