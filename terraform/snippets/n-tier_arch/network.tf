resource "oci_core_virtual_network" "AppVCN" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "AppVCN-TF"
  dns_label      = "appvcntf"
}

resource "oci_core_internet_gateway" "AppIGW" {
  compartment_id = var.compartment_ocid
  display_name   = "AppIGW"
  vcn_id         = oci_core_virtual_network.AppVCN.id
}

/* Load Balancer subnet - regional and public */
resource "oci_core_subnet" "LB-Subnet1" {
  cidr_block          = "10.1.1.0/24"
  display_name        = "LB-Reg-Sub"
  dns_label           = "lbregsub"
  security_list_ids   = [oci_core_security_list.LB_SecurityList.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.AppVCN.id
  route_table_id      = oci_core_route_table.IgwRT.id
  dhcp_options_id     = oci_core_virtual_network.AppVCN.default_dhcp_options_id

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

/* Bastion host subnet - regional and public */
resource "oci_core_subnet" "Bastion-Subnet1" {
  cidr_block          = "10.1.2.0/24"
  display_name        = "BAS-Reg-Sub"
  dns_label           = "basregsub"
  security_list_ids   = [oci_core_security_list.Bas_SecurityList.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.AppVCN.id
  route_table_id      = oci_core_route_table.IgwRT.id
  dhcp_options_id     = oci_core_virtual_network.AppVCN.default_dhcp_options_id

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

/* front-end web server subnet - regional and private */
resource "oci_core_subnet" "fe-sub" {
  cidr_block          		    = "10.1.10.0/24"
  display_name        		    = "FE-Sub"
  dns_label           		    = "feregsubpriv"
  prohibit_public_ip_on_vnic 	= "true"
  security_list_ids   		    = [oci_core_security_list.FE_SecurityList.id]
  compartment_id      		    = var.compartment_ocid
  vcn_id              		    = oci_core_virtual_network.AppVCN.id
  route_table_id      		    = oci_core_route_table.FE-priv-RT.id
  dhcp_options_id     		    = oci_core_virtual_network.AppVCN.default_dhcp_options_id

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

/* Load Balancer security list */
resource "oci_core_security_list" "LB_SecurityList" {
    compartment_id  = var.compartment_ocid
    display_name    = "LoadBalancerSL"
    vcn_id          = oci_core_virtula_network.AppVCN.id
    
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
        min = "80"
        max = "80"
      }
    }
}

/* Bastion host security list */
resource "oci_core_security_list" "Bas_SecurityList" {
    compartment_id    = var.compartment_ocid
    display_name      = "BastionSL"
    vcn_id            = oci_core_virtual_network.AppVCN.id
    
    egress_security_rules {
        protocol    = "all"
        destination = "0.0.0.0/0"
    }
    ingress_security_rules {
      protocol  = 1
      source    = "10.1.0.0/16"
      stateless = true
    }
    ingress_security_rules {
      protocol  = 6
      source    = "0.0.0.0/0"

      tcp_options {
        min = "22"
        max = "22"
      }
    }
}

/* Frontend app server security list */
resource "oci_core_security_list" "FE_SecurityList" {
    compartment_id  = var.compartment_ocid
    display_name    = "FEAppSL"
    vcn_id          = oci_core_virtual_network.AppVCN.id
    
    egress_security_rules {
        protocol    = "all"
        destination = "0.0.0.0/0"
    }
    ingress_security_rules {
      protocol  = 1
      source    = "10.1.0.0/16"
      stateless = true
    }
    ingress_security_rules {
      protocol  = 6
      source    = "10.1.1.0/24"

      tcp_options {
        min = "80"
        max = "80"
      }
    }
    ingress_security_rules {
      protocol  = 6
      source    = "10.1.0.0/16"

      tcp_options {
        min = "22"
        max = "22"
      }
    }
}

resource "oci_core_route_table" "IgwRT" {
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_virtual_network.AppVCN.id
  display_name    = "PubIgwRT"
  
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.AppIGW.id
  }
}

/* Route table for front-end app server subnet - NAT to internet */
resource "oci_core_route_table" "FE-priv-RT" {
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_virtual_network.AppVCN.id
  display_name    = "FrontEndAppRT"

  route_rules {
    destination		      = "0.0.0.0/0"
    destination_type	  = "CIDR_BLOCK"
    network_entity_id 	= oci_core_nat_gateway.nat_gateway.id
  }
}

/* NAT gateway for private subnets to access YUM repos */
resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.AppVCN.id
  display_name   = "nat_gateway"
}


