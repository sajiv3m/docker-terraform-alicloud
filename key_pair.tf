# Definition for the SSH key pair to use
# Generate the key pair using ssh-keygen and copy public key
resource "alicloud_key_pair" "publickey" {
    key_name = "docker_alicloud_key"
    public_key = "${var.PUBLIC_KEY}"
}
