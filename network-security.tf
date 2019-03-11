# Definition for VPC, vSwitch, Security group and secuirty / firewall rules

# Define VPC
resource "alicloud_vpc" "mydockernetwork" {
  name = "${var.DOCKER_VPC_NAME}"
  cidr_block = "${var.DOCKER_VPC_CIDR}"
}

# Define vSwitch
resource "alicloud_vswitch" "mydockernetwork" {
  name              = "${var.DOCKER_VSWITCH_NAME}"
  availability_zone = "${var.ALICLOUD_AZ}"
  cidr_block        = "${var.DOCKER_VSWITCH_CIDR}"
  vpc_id            = "${alicloud_vpc.mydockernetwork.id}"
}

# Define Security group
resource "alicloud_security_group" "mydockernetwork" {
  name        = "${var.DOCKER_SG_NAME}"
  description = "Docker Security Group"
  vpc_id = "${alicloud_vpc.mydockernetwork.id}"
}

# Define security / firewall rules
resource "alicloud_security_group_rule" "ssh-in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.mydockernetwork.id}"
  cidr_ip           = "${var.MY_PUBLIC_IP}"
  
}

resource "alicloud_security_group_rule" "docker-ucp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "8070/8090"
  priority          = 2
  security_group_id = "${alicloud_security_group.mydockernetwork.id}"
  cidr_ip           = "0.0.0.0/0"
  
}

resource "alicloud_security_group_rule" "docker-dtr" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 3
  security_group_id = "${alicloud_security_group.mydockernetwork.id}"
  cidr_ip           = "0.0.0.0/0"
  
}

resource "alicloud_security_group_rule" "docker-dtr-ssl" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 4
  security_group_id = "${alicloud_security_group.mydockernetwork.id}"
  cidr_ip           = "0.0.0.0/0"
  
}

resource "alicloud_security_group_rule" "kubernetes" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "6443/6443"
  priority          = 5
  security_group_id = "${alicloud_security_group.mydockernetwork.id}"
  cidr_ip           = "0.0.0.0/0"
  
}


resource "alicloud_security_group_rule" "rdp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "3389/3389"
  priority          = 6
  security_group_id = "${alicloud_security_group.mydockernetwork.id}"
  cidr_ip           = "${var.MY_PUBLIC_IP}"
  
}

resource "alicloud_security_group_rule" "winrm" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "5985/5986"
  priority          = 7
  security_group_id = "${alicloud_security_group.mydockernetwork.id}"
  cidr_ip           = "${var.MY_PUBLIC_IP}"
  
}