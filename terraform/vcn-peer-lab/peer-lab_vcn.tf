variable "MGMT-VCN-CIDR"  {
  default = "10.0.0.0/16"
}

variable "MKTG-VCN-CIDR"  {
  default = "10.10.0.0/16"
}

variable "ENG-VCN-CIDR" {
  default = "10.20.0.0/16"
}

# ---------------------------------
# Management VCN and resources
# ---------------------------------

resource "oci_core_virtual_network" "Management" {
  cidr_block = "${var.MGMT-VCN-CIDR}"
  dns_label = "management"
  compartment_id = "${var.compartment_ocid}"
  display_name = "management"
}

resource "oci_core_internet_gateway" "ManagementIGW" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "ManagementIGW"
  vcn_id         = "${oci_core_virtual_network.Management.id}"
}

resource "oci_core_local_peering_gateway" "MgmtLPG-to-MktgLPG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.Management.id}"
  display_name = "MgmtLPG-to-MktgLPG"
  peer_id = "${oci_core_local_peering_gateway.MktgLPG-to-MgmtLPG.id}"
}

resource "oci_core_local_peering_gateway" "MgmtLPG-to-EngLPG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.Management.id}"
  display_name = "MgmtLPG-to-EngLPG"
  peer_id = "${oci_core_local_peering_gateway.EngLPG-to-MgmtLPG.id}"
}

resource "oci_core_route_table" "ManagementRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.Management.id}"
  display_name = "ManagementRT"
  route_rules = [{
    destination = "${var.MKTG-VCN-CIDR}"
    destination_type = "CIDR_BLOCK"
    network_entity_id = "${oci_core_local_peering_gateway.MgmtLPG-to-MktgLPG.id}"
  },
  {
    destination = "${var.ENG-VCN-CIDR}"
    destination_type = "CIDR_BLOCK"
    network_entity_id = "${oci_core_local_peering_gateway.MgmtLPG-to-EngLPG.id}"
  },
  {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.ManagementIGW.id}"
  }]
}

resource "oci_core_security_list" "ManagementSecurityList" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "Management Security List"
    vcn_id = "${oci_core_virtual_network.Management.id}"
    egress_security_rules = [{
        protocol = "all"
        destination = "0.0.0.0/0"
    }]
    ingress_security_rules = [{
      protocol  = 1
      source    = "${var.MKTG-VCN-CIDR}"
      stateless = true
    },
    {
      protocol  = 1
      source    = "${var.ENG-VCN-CIDR}"
      stateless = true
    },
    {
      protocol = 6
      source = "0.0.0.0/0"

      tcp_options {
        min = "22"
        max = "22"
      }
    }]
}

# -----------------------------
# Marketing Network Resources
# -----------------------------

resource "oci_core_virtual_network" "Marketing" {
  cidr_block = "${var.MKTG-VCN-CIDR}"
  dns_label = "Marketing"
  compartment_id = "${var.compartment_ocid}"
  display_name = "Marketing"
}

resource "oci_core_local_peering_gateway" "MktgLPG-to-MgmtLPG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.Marketing.id}"
  display_name = "MktgLPG-to-MgmtLPG"
}

resource "oci_core_route_table" "MarketingRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.Marketing.id}"
  display_name = "MarketingRT"
  route_rules {
    destination = "${var.MGMT-VCN-CIDR}"
    destination_type = "CIDR_BLOCK"
    network_entity_id = "${oci_core_local_peering_gateway.MktgLPG-to-MgmtLPG.id}"
  }
}

resource "oci_core_security_list" "MarketingSecurityList" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "Marketing Security List"
    vcn_id = "${oci_core_virtual_network.Marketing.id}"
    egress_security_rules = [{
        protocol = "all"
        destination = "0.0.0.0/0"
    }]
    ingress_security_rules = [{
      protocol  = 1
      source    = "${var.MGMT-VCN-CIDR}"
      stateless = true
    },
    {
      protocol = 6
      source = "${var.MGMT-VCN-CIDR}"

      tcp_options {
        min = "22"
        max = "22"
      }
    }]
}

# -----------------------------
# Engineering Network Resources
# -----------------------------

resource "oci_core_virtual_network" "Engineering" {
  cidr_block = "${var.ENG-VCN-CIDR}"
  dns_label = "Engineering"
  compartment_id = "${var.compartment_ocid}"
  display_name = "Engineering"
}

resource "oci_core_local_peering_gateway" "EngLPG-to-MgmtLPG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.Engineering.id}"
  display_name = "EngLPG-to-MgmtLPG"
}

resource "oci_core_route_table" "EngineeringRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.Engineering.id}"
  display_name = "EngineeringRT"
  route_rules {
    destination = "${var.MGMT-VCN-CIDR}"
    destination_type = "CIDR_BLOCK"
    network_entity_id = "${oci_core_local_peering_gateway.EngLPG-to-MgmtLPG.id}"
  }
}

resource "oci_core_security_list" "EngineeringSecurityList" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "Engineering Security List"
    vcn_id = "${oci_core_virtual_network.Engineering.id}"
    egress_security_rules = [{
        protocol = "all"
        destination = "0.0.0.0/0"
    }]
    ingress_security_rules = [{
      protocol  = 1
      source    = "${var.MGMT-VCN-CIDR}"
      stateless = true
    },
    {
      protocol = 6
      source = "${var.MGMT-VCN-CIDR}"

      tcp_options {
        min = "22"
        max = "22"
      }
    }]
}
