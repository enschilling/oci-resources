# ------------------------------------
# Release notes
# Updated: 10/30/2018
# Added image OCID lookup
# ------------------------------------

# ------------------------------------
# Initialize variables
# ------------------------------------

data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

data "oci_core_images" "OL75ImageOCID" {
        compartment_id = "${var.compartment_ocid}"
        operating_system = "Oracle Linux"
        operating_system_version = "7.5"
        #compatible shape
        shape = "VM.Standard2.1"
}

variable "InstanceImageOCID" {
  type = "map"

default = {
  // Oracle-provided image "Oracle-Linux-7.5-2018.08.14-0"
  // See https://docs.cloud.oracle.com/iaas/images/oraclelinux-7x/
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaasez4lk2lucxcm52nslj5nhkvbvjtfies4yopwoy4b3vysg5iwjra"
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaa2tq67tvbeavcmioghquci6p3pvqwbneq3vfy7fe7m7geiga4cnxa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaakzrywmh7kwt7ugj5xqi5r4a7xoxsrxtc7nlsdyhmhqyp7ntobjwq"
    eu-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaalsdgd47nl5tgb55sihdpqmqu2sbvvccjs6tmbkr4nx2pq5gkn63a"
  }
}

# ---------------------------------------
# Management Subnet and compute instance
# ---------------------------------------

resource "oci_core_subnet" "MGMT-Subnet1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "10.0.0.0/24"
  display_name        = "MgmtSub1"
  dns_label           = "mgmtsub1"
  security_list_ids   = ["${oci_core_security_list.ManagementSecurityList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.Management.id}"
  route_table_id      = "${oci_core_route_table.ManagementRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.Management.default_dhcp_options_id}"

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_core_instance" "MGMTInstance" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MGMT-instance"
  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.OL75ImageOCID.images[0], "id")}"
  }
  shape               = "VM.Standard2.1"
  subnet_id           = "${oci_core_subnet.MGMT-Subnet1.id}"
  hostname_label      = "MGMT-instance"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(var.user-data)}"
  }
}

# ---------------------------------------
# Marketing Subnet and compute intance
# ---------------------------------------

resource "oci_core_subnet" "MKTG-Subnet1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "10.10.0.0/24"
  display_name        = "MktgSub1"
  dns_label           = "mktgsub1"
  security_list_ids   = ["${oci_core_security_list.MarketingSecurityList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.Marketing.id}"
  route_table_id      = "${oci_core_route_table.MarketingRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.Marketing.default_dhcp_options_id}"

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_core_instance" "MKTGInstance" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MKTG-instance"
  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.OL75ImageOCID.images[0], "id")}"
  }
  shape               = "VM.Standard2.1"
  subnet_id           = "${oci_core_subnet.MKTG-Subnet1.id}"
  hostname_label      = "MKTG-instance"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(var.user-data)}"
  }
}

# ----------------------------------------
# Engineering Subnet and Compute instance
# ----------------------------------------

resource "oci_core_subnet" "ENG-Subnet1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "10.20.0.0/24"
  display_name        = "ENGSub1"
  dns_label           = "engsub1"
  security_list_ids   = ["${oci_core_security_list.EngineeringSecurityList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.Engineering.id}"
  route_table_id      = "${oci_core_route_table.EngineeringRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.Engineering.default_dhcp_options_id}"

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_core_instance" "ENGInstance" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "ENG-instance"
  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.OL75ImageOCID.images[0], "id")}"
  }
  shape = "VM.Standard2.1"
  subnet_id           = "${oci_core_subnet.ENG-Subnet1.id}"
  hostname_label      = "ENG-instance"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(var.user-data)}"
  }
}

# ------------------------------------
# Common userdata for all 3 instances
# ------------------------------------

variable "user-data" {
  default = <<EOF
#!/bin/bash -x
echo '################### OCI Server userdata begins #####################'
touch ~opc/userdata.`date +%s`.start

# echo '########## yum update all ###############'
# yum update -y

echo '########## what else would you like to do? ##############'
#
# you can enter more commands here
#

touch ~opc/userdata.`date +%s`.finish
echo '################### webserver userdata ends #######################'
EOF
}
