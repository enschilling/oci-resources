### Authentication details
provider "oci" {
  compartment_ocid = "${var.compartment_ocid}"
  region           = "${var.region}"
}

variable "tenancy_ocid" {
}
### Compartment
variable "compartment_ocid" {
}

### Public/private keys used on the instances
variable "ssh_public_key" {
}
### Region
variable region {
    default = "us-phoenix-1"
  }
