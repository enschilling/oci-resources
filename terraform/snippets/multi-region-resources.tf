### Authentication details
provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region = "${var.region}"
}
 
provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region = "us-phoenix-1"
  alias = "phx"
  disable_auto_retries = "true"
}

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
 
 
### Resource Definitions
resource "oci_core_virtual_network" "vcn1" {
  cidr_block = "10.0.0.0/16"
  dns_label = "vnc1"
  compartment_id = "${var.tenancy_ocid}"
  display_name = "vnc1"
}
 
resource "oci_core_virtual_network" "vcn2" {
  provider = "oci.phx"
  cidr_block = "10.0.0.0/16"
  dns_label = "vnn2"
  compartment_id = "${var.tenancy_ocid}"
  display_name = "vnc2"
}
 
output "ash-vcn" {
  value = ["${oci_core_virtual_network.vcn1.id}"]
}
output "phx-vcn" {
  value = ["${oci_core_virtual_network.vcn2.id}"]
}

