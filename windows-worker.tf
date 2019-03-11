
# Definition for the Linux worker host which will be joined to the Docker Swarm created by the UCP host

data "template_file" "enable_winrm" {
  template = "${file("win-files/winrm.ps1")}"
}

resource "alicloud_instance" "mywinworker1" {
  instance_name     = "winworker1"
  host_name         = "winworker1"
  image_id          = "win2016_64_dtc_1607_en-us_40G_alibase_20181220.vhd"
  instance_type     = "ecs.t5-lc1m4.large"
  vswitch_id        = "${alicloud_vswitch.mydockernetwork.id}"
  security_groups   = ["${alicloud_security_group.mydockernetwork.id}"]
  instance_charge_type = "PostPaid"
  internet_max_bandwidth_out = 100
  password          = "${var.DOCKER_SERVER_PASSWORD}"
  system_disk_category = "cloud_efficiency"
  user_data         = "${data.template_file.enable_winrm.template}"
  

# Copy scripts and files for linux hosts from win-files folder to c:/terraform on target VM
  provisioner "file" {
    source = "win-files"
    destination = "C:\\terraform"
  }

# Installing Docker Enterprise on the Windows worker node

  provisioner "remote-exec" {
    inline = [
      "cd C:\\terraform",
      "powershell.exe -sta -WindowStyle Hidden -ExecutionPolicy Unrestricted -file C:\\terraform\\install-win-docker-ee.ps1"
    ]
  }

/*Windows VM must be restarted after installing Docker EE
  forcing execution to sleep 5 minutes for the VM to finish restart */
  provisioner "local-exec" {
    command = "sleep 300"
  }

# Joining the Windows host to Docker Swarm as a worker node
  provisioner "remote-exec" {
    inline = [
      "cd C:\\terraform",
      "powershell.exe -sta -WindowStyle Hidden -ExecutionPolicy Unrestricted -file C:\\terraform\\configure-win-docker.ps1 ${alicloud_instance.mydockervm.public_ip} ${var.DOCKER_ADMIN_USER} ${var.DOCKER_ADMIN_PASSWORD} ${var.DOCKER_UCP_PORT}"
    ]
  } 

  connection {
    type = "winrm"
    timeout = "10m"
    host = "${alicloud_instance.mywinworker1.public_ip}"
    user = "Administrator"
    password = "${var.DOCKER_SERVER_PASSWORD}"
  }


  tags {
    project   = "Docker Demo"
  }
}




