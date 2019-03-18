### Authentication details
provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region = "${var.region}"
}

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "ssh_public_key" {}
variable "ssh_private_key" {}

variable "root_compartment_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaaff2avv7uvhyylobvvjbjbmhaugejqbdgscj2us2vwfhjtpltfkjq"
}

variable "resourceCount" {
  default = 20
}

### Resource Definitions
resource "oci_identity_compartment" "training_compartments" {
  count = "${var.resourceCount}"
  compartment_id = "${var.root_compartment_ocid}"
  description = "Training Compartment ${format("%02d", count.index + 1)}"
  name = "train${format("%02d", count.index + 1)}"
}

#####################################
##          Create Groups         ###
#####################################

resource "oci_identity_group" "training_groups_nas" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User Group ${format("%02d", count.index + 1)} - NAS"
  name = "grpTraining_nas_${format("%02d", count.index + 1)}"
}

resource "oci_identity_group" "training_groups_lhr" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User Group ${format("%02d", count.index + 1)} - LHR"
  name = "grpTraining_lhr_${format("%02d", count.index + 1)}"
}

resource "oci_identity_group" "training_groups_fra" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User Group ${format("%02d", count.index + 1)} - FRA"
  name = "grpTraining_fra_${format("%02d", count.index + 1)}"
}

resource "oci_identity_group" "training_groups_yyz" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User Group ${format("%02d", count.index + 1)} - YYZ"
  name = "grpTraining_yyz_${format("%02d", count.index + 1)}"
}

#####################################
##          Create Users          ###
#####################################

resource "oci_identity_user" "training_users_phx" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User ${format("%02d", count.index + 1)} - PHX"
  name = "trainUser_phx_${format("%02d", count.index + 1)}"
}

resource "oci_identity_user" "training_users_iad" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User ${format("%02d", count.index + 1)} - IAD"
  name = "trainUser_iad_${format("%02d", count.index + 1)}"
}

resource "oci_identity_user" "training_users_lhr" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User ${format("%02d", count.index + 1)} - LHR"
  name = "trainUser_lhr_${format("%02d", count.index + 1)}"
}

resource "oci_identity_user" "training_users_fra" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User ${format("%02d", count.index + 1)} - FRA"
  name = "trainUser_fra_${format("%02d", count.index + 1)}"
}

resource "oci_identity_user" "training_users_yyz" {
  count = "${var.resourceCount}"
  compartment_id = "${var.tenancy_ocid}"
  description = "Training User ${format("%02d", count.index + 1)} - YYZ"
  name = "trainUser_yyz_${format("%02d", count.index + 1)}"
}

#####################################
##      Create Group Membership   ###
#####################################


resource "oci_identity_user_group_membership" "training_group_membership_phx" {
  count = "${var.resourceCount}"
  group_id = "${oci_identity_group.training_groups_nas.*.id[count.index]}"
  user_id = "${oci_identity_user.training_users_phx.*.id[count.index]}"
}

resource "oci_identity_user_group_membership" "training_group_membership_iad" {
  count = "${var.resourceCount}"
  group_id = "${oci_identity_group.training_groups_nas.*.id[count.index]}"
  user_id = "${oci_identity_user.training_users_iad.*.id[count.index]}"
}

resource "oci_identity_user_group_membership" "training_group_membership_lhr" {
  count = "${var.resourceCount}"
  group_id = "${oci_identity_group.training_groups_lhr.*.id[count.index]}"
  user_id = "${oci_identity_user.training_users_lhr.*.id[count.index]}"
}

resource "oci_identity_user_group_membership" "training_group_membership_fra" {
  count = "${var.resourceCount}"
  group_id = "${oci_identity_group.training_groups_fra.*.id[count.index]}"
  user_id = "${oci_identity_user.training_users_fra.*.id[count.index]}"
}

resource "oci_identity_user_group_membership" "training_group_membership_yyz" {
  count = "${var.resourceCount}"
  group_id = "${oci_identity_group.training_groups_yyz.*.id[count.index]}"
  user_id = "${oci_identity_user.training_users_yyz.*.id[count.index]}"
}

#####################################
##      Create IAM Policies       ###
#####################################

resource "oci_identity_policy" "training_user_policy_nas" {
  count = "${var.resourceCount}"
  compartment_id = "${oci_identity_compartment.training_compartments.*.id[count.index]}"
  name = "TrainingPolicy-Compartment${format("%02d", count.index + 1)}-NAS"
  description = "Training group policy for compartment ${count.index + 1}, PHX - IAD users"
  statements = ["Allow group ${oci_identity_group.training_groups_nas.*.name[count.index]} to manage all-resources in compartment ${oci_identity_compartment.training_compartments.*.name[count.index]} where ANY {request.region = 'phx', request.region = 'iad'}"]
}

resource "oci_identity_policy" "training_user_policy_lhr" {
  count = "${var.resourceCount}"
  compartment_id = "${oci_identity_compartment.training_compartments.*.id[count.index]}"
  name = "TrainingPolicy-Compartment${format("%02d", count.index + 1)}-LHR"
  description = "Training group policy for compartment ${count.index + 1}, LHR user"
  statements = ["Allow group ${oci_identity_group.training_groups_lhr.*.name[count.index]} to manage all-resources in compartment ${oci_identity_compartment.training_compartments.*.name[count.index]} where request.region = 'lhr'"]
}

resource "oci_identity_policy" "training_user_policy_fra" {
  count = "${var.resourceCount}"
  compartment_id = "${oci_identity_compartment.training_compartments.*.id[count.index]}"
  name = "TrainingPolicy-Compartment${format("%02d", count.index + 1)}-FRA"
  description = "Training group policy for compartment ${count.index + 1}, FRA user"
  statements = ["Allow group ${oci_identity_group.training_groups_fra.*.name[count.index]} to manage all-resources in compartment ${oci_identity_compartment.training_compartments.*.name[count.index]} where request.region = 'fra'"]
}

resource "oci_identity_policy" "training_user_policy_yyz" {
  count = "${var.resourceCount}"
  compartment_id = "${oci_identity_compartment.training_compartments.*.id[count.index]}"
  name = "TrainingPolicy-Compartment${format("%02d", count.index + 1)}-YYZ"
  description = "Training group policy for compartment ${count.index + 1}, YYZ user"
  statements = ["Allow group ${oci_identity_group.training_groups_yyz.*.name[count.index]} to manage all-resources in compartment ${oci_identity_compartment.training_compartments.*.name[count.index]} where request.region = 'yyz'"]
}

#####################################
##      Set User Passwords        ###
#####################################

resource "oci_identity_ui_password" "training_user_passwords_phx" {
  count = "${var.resourceCount}"
  user_id = "${oci_identity_user.training_users_phx.*.id[count.index]}"
}

resource "oci_identity_ui_password" "training_user_passwords_iad" {
  count = "${var.resourceCount}"
  user_id = "${oci_identity_user.training_users_iad.*.id[count.index]}"
}

resource "oci_identity_ui_password" "training_user_passwords_lhr" {
  count = "${var.resourceCount}"
  user_id = "${oci_identity_user.training_users_lhr.*.id[count.index]}"
}

resource "oci_identity_ui_password" "training_user_passwords_fra" {
  count = "${var.resourceCount}"
  user_id = "${oci_identity_user.training_users_fra.*.id[count.index]}"
}

resource "oci_identity_ui_password" "training_user_passwords_yyz" {
  count = "${var.resourceCount}"
  user_id = "${oci_identity_user.training_users_yyz.*.id[count.index]}"
}

#####################################
##      Designated Outputs        ###
#####################################

output "User_passwords_phx" {
  sensitive = false
  value = "${concat(oci_identity_user.training_users_phx.*.name,oci_identity_ui_password.training_user_passwords_phx.*.password)}"
}

output "User_passwords_iad" {
  sensitive = false
  value = "${concat(oci_identity_user.training_users_iad.*.name,oci_identity_ui_password.training_user_passwords_iad.*.password)}"
}

output "User_passwords_lhr" {
  sensitive = false
  value = "${concat(oci_identity_user.training_users_lhr.*.name,oci_identity_ui_password.training_user_passwords_lhr.*.password)}"
}

output "User_passwords_fra" {
  sensitive = false
  value = "${concat(oci_identity_user.training_users_fra.*.name,oci_identity_ui_password.training_user_passwords_fra.*.password)}"
}

output "User_passwords_yyz" {
  sensitive = false
  value = "${concat(oci_identity_user.training_users_yyz.*.name,oci_identity_ui_password.training_user_passwords_yyz.*.password)}"
}
