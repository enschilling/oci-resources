### Authentication details
provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region = "${var.region}"
  disable_auto_retries = "true"
}

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "ssh_public_key" {}
variable "ssh_private_key" {}

variable "resourceCount" {
  default = 10
}

### Resource Definitions
resource "oci_identity_compartment" "training_compartments" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training Compartment ${format("%02d", count.index + 1)}"
  name = "train${format("%02d", count.index + 1)}"
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  triggers = {
    "training_compartments" = "${oci_identity_compartment.training_compartments.0.id}"
  }
}

resource "oci_identity_group" "training_groups" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User Group ${format("%02d", count.index + 1)}"
  name = "grpTraining_${format("%02d", count.index + 1)}"
}

resource "oci_identity_user" "training_users" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User ${format("%02d", count.index + 1)}"
  name = "trainUser${format("%02d", count.index + 1)}"
}

resource "oci_identity_user_group_membership" "training_group_membership" {
  count = "${var.resourceCount}"
  group_id = "${oci_identity_group.training_groups.*.id[count.index]}"
  user_id = "${oci_identity_user.training_users.*.id[count.index]}"
}

resource "oci_identity_policy" "training_user_policy" {
  depends_on = ["null_resource.delay"]
  count = "${var.resourceCount}"
  compartment_id = "${oci_identity_compartment.training_compartments.*.id[count.index]}"
  name = "TrainingPolicy-Compartment${format("%02d", count.index + 1)}"
  description = "Training group policy for compartment ${count.index + 1}"
  statements = ["Allow group ${oci_identity_group.training_groups.*.name[count.index]} to manage all-resources in compartment ${oci_identity_compartment.training_compartments.*.name[count.index]}"]
}

resource "oci_identity_ui_password" "training_user_passwords" {
  count = "${var.resourceCount}"
  user_id = "${oci_identity_user.training_users.*.id[count.index]}"
}

### Outputs section ###
output "User_passwords" {
  sensitive = false
  value = "${concat(oci_identity_user.training_users.*.name,oci_identity_ui_password.training_user_passwords.*.password)}"
}
