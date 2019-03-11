# Definition for the main docker VM which hosts UCP, DTR components

resource "alicloud_instance" "mydockervm" {
  instance_name     = "dockervm"
  host_name         = "dockervm"
  image_id          = "ubuntu_18_04_64_20G_alibase_20190223.vhd"
  instance_type     = "ecs.t5-c1m4.xlarge"
  vswitch_id        = "${alicloud_vswitch.mydockernetwork.id}"
  security_groups   = ["${alicloud_security_group.mydockernetwork.id}"]
  instance_charge_type = "PostPaid"
  internet_max_bandwidth_out = 100
  key_name          = "${alicloud_key_pair.publickey.key_name}"
  system_disk_category = "cloud_efficiency"


# Copy scripts and files for linux hosts from lin-files folder to /tmp on target VM
  provisioner "file" {
    source = "lin-files"
    destination = "/tmp"
  } 

# Installing Docker Enterprise on the UCP host
# Key parameters are Docker Licence URL, Docker EE version, Docker EE Release, Docker user for the host 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/lin-files/install*.sh",
      "/tmp/lin-files/install_docker_ee.sh \"${var.DOCKER_EE_URL}\" \"${var.DOCKER_EE_VERSION}\" \"${var.DOCKER_EE_RELEASE}\" \"${var.DOCKER_SERVER_USER}\""
    ]
  }

  provisioner "remote-exec" {
    inline = [
# Installing Docker UCP with parameters - UCP version, FQDN/Public IP of UCP host, Docker ADMIN, Docker Admin password, private IP of UCP host, SSL port to use for UCP host, CIDR to use for Kubernetes Pods
      "/tmp/lin-files/install_docker_ucp.sh \"${var.DOCKER_UCP_VERSION}\" \"${alicloud_instance.mydockervm.public_ip}\" \"${var.DOCKER_ADMIN_USER}\" \"${var.DOCKER_ADMIN_PASSWORD}\" \"${alicloud_instance.mydockervm.private_ip}\" \"${var.DOCKER_UCP_PORT}\" \"${var.POD_CIDR}\"",
/*  Installing DTR with parameters - FQDN/public IP of UCP and DTR host, Docker ADMIN, Docker Admin password, SSL port used for UCP host
    DTR will be installed on the same host as UCP. */
      "/tmp/lin-files/install_docker_dtr.sh \"${alicloud_instance.mydockervm.public_ip}\" \"${var.DOCKER_ADMIN_USER}\" \"${var.DOCKER_ADMIN_PASSWORD}\" \"${var.DOCKER_UCP_PORT}\""
    ]
  }

# Connection details for all the remote-exec and remote file copy (provisioner - file) mentioned above
  connection {
    host = "${alicloud_instance.mydockervm.public_ip}"
    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
  }

  tags {
    project   = "Docker Demo"
  }
}




