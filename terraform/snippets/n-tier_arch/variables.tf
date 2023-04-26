variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}

# Required for remote SSH access to Bastion and/or Web Server
variable "ssh_public_key" {}
variable "ssh_private_key" {}

# Not required for Resource Manager
# Uncomment and assign values when using Cloud Shell or local Terraform install
#variable "user_ocid" {}
#Evariable "fingerprint" {}
#variable "private_key_path" {}

data "oci_identity_availability_domain" "ad" {
  compartment_id  = var.tenancy_ocid
  ad_number       = 1
}

variable "EnvType" {
  default = "dev"
}

variable "ComputeShape" {

  default = "VM.Standrad.E3.Flex"
}

variable "ComputeShapeOCPU" {
  type = "map"

default = {
  dev   = 2
  qa    = 4
  prod  = 8
  }
}

variable "ComputeShapeMem" {
  type = "map"

default = {
  dev   = 16
  qa    = 32
  prod  = 64
  }
}

data "oci_core_images" "OL87ImageOCID" {
        compartment_id = var.compartment_ocid
        operating_system = "Oracle Linux"
        operating_system_version = 8.7
        #compatible shape
        shape = var.ComputeShape
}
