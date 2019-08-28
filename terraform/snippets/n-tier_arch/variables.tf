variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "region" {
}

variable "compartment_ocid" {
}

variable "ssh_public_key" {
}

variable "ssh_private_key" {
}

# Choose an Availability Domain
variable "AD" {
  default = "1"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

variable "EnvType" {
  default = "dev"
}

variable "ComputeShape" {
  type = "map"

default = {
  dev = "VM.Standard2.1"
  qa = "VM.Standard2.4"
  prod = "DM.DenseIO2.52"
  }
}

data "oci_core_images" "OL76ImageOCID" {
        compartment_id = "${var.compartment_ocid}"
        operating_system = "Oracle Linux"
        operating_system_version = "7.6"
        #compatible shape
        shape = "VM.Standard2.1"
}
