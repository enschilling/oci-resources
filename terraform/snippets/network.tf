resource "oci_core_vcn" "AppVCN" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "AppVCN-TF"
  dns_label      = "appvcntf"
}

resource "oci_core_internet_gateway" "AppIGW" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "AppIGW"
  vcn_id         = "${oci_core_vcn.AppVCN.id}"
}

resource "oci_core_subnet" "LB-Subnet1" {
  cidr_block          = "10.1.1.0/24"
  display_name        = "LB-Reg-Sub"
  dns_label           = "lbregsub"
  security_list_ids   = ["${oci_core_security_list.LB_SecurityList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.AppVCN.id}"
  route_table_id      = "${oci_core_route_table.IgwRT.id}"
  dhcp_options_id     = "${oci_core_vcn.AppVCN.default_dhcp_options_id}"

  provisioner "local-exec" {
    command = "sleep 5"
  }
}


resource "oci_core_security_list" "LB_SecurityList" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "LoadBalancerSL"
    vcn_id = "${oci_core_vcn.AppVCN.id}"
    egress_security_rules {
        protocol = "all"
        destination = "0.0.0.0/0"
    }
    ingress_security_rules {
      protocol  = 1
      source    = "10.1.0.0/16"
      stateless = true
    }
    ingress_security_rules {
      protocol = 6
      source = "0.0.0.0/0"

      tcp_options {
        min = "22"
        max = "22"
      }
    }
}

resource "oci_core_route_table" "IgwRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_vcn.AppVCN.id}"
  display_name = "LoadBalancerRT"
  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.AppIGW.id}"
  }
}
