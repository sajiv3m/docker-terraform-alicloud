# Definition for the Linux worker host which will be joined to the Docker Swarm created by the UCP host

resource "alicloud_instance" "mylinworker1" {
  instance_name     = "linworker1"
  host_name         = "linworker1"
  image_id          = "ubuntu_18_04_64_20G_alibase_20190223.vhd"
  instance_type     = "ecs.t5-lc1m4.large"
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

# Installing Docker Enterprise on the Linux worker node
# Key parameters are Docker Licence URL, Docker EE version, Docker EE Release, Docker user for the host 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/lin-files/install*.sh",
      "/tmp/lin-files/install_docker_ee.sh \"${var.DOCKER_EE_URL}\" \"${var.DOCKER_EE_VERSION}\" \"${var.DOCKER_EE_RELEASE}\" \"${var.DOCKER_SERVER_USER}\""
    ]
  }

/*  Must login second time separately to ensure docker groupID change is in effect
    for the reason mentioned above, second block of remote-exec used */
  provisioner "remote-exec" {
    inline = [
# Joining the Linux host to the Docker Swarm as a Worker node
      "/tmp/lin-files/install_docker_worker_node.sh \"${alicloud_instance.mydockervm.public_ip}\" \"${var.DOCKER_ADMIN_USER}\" \"${var.DOCKER_ADMIN_PASSWORD}\" \"${var.DOCKER_UCP_PORT}\""
    ]
  }

# Connection details for all the remote-exec and remote file copy (provisioner - file) mentioned above
  connection {
    host = "${alicloud_instance.mylinworker1.public_ip}"
    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
  }

  tags {
    project   = "Docker Demo"
  }
}
