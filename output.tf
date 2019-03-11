
# Print the IP addresses for Docker UCP and Linux worker hosts

output "Docker UCP host ip_address" {
  value = "${alicloud_instance.mydockervm.public_ip}"
}

output "Linux worker ip_address" {
  value = "${alicloud_instance.mylinworker1.public_ip}"
}


output "Windows worker ip_address" {
  value = "${alicloud_instance.mywinworker1.public_ip}"
}


output "Docker UCP url" {
  value = "https://${alicloud_instance.mydockervm.public_ip}:${var.DOCKER_UCP_PORT}/"
}

output "Docker DTR url" {
  value = "https://${alicloud_instance.mydockervm.public_ip}/"
}
