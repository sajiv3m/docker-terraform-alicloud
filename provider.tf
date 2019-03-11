# Definition file for the cloud provider - Alibaba Cloud
# Access keys are in the terraform.tfvars file

provider "alicloud" {
  access_key = "${var.ALICLOUD_ACCESS_KEY}"
  secret_key = "${var.ALICLOUD_SECRET_KEY}"
  region     = "${var.ALICLOUD_REGION}"
}