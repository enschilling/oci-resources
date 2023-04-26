/* Load Balancer */

resource "oci_load_balancer" "AppLB" {
  shape          = "flexible"
  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.LB-Subnet1.id,
  ]

  display_name = "AppLB"

  shape_details {
    maximum_bandwidth_in_mbps = 40
    minimum_bandwidth_in_mbps = 10

  }
}

resource "oci_load_balancer_backend_set" "lb-bes1" {
  name             = "lb-bes1"
  load_balancer_id = oci_load_balancer.AppLB.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource "oci_load_balancer_listener" "lb-listener1" {
  load_balancer_id         = oci_load_balancer.AppLB.id
  name                     = "frontend"
  default_backend_set_name = oci_load_balancer_backend_set.lb-bes1.name
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

resource "oci_load_balancer_backend" "lb-be1" {
  load_balancer_id = oci_load_balancer.AppLB.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = oci_core_instance.frontend-01.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-be2" {
  load_balancer_id = oci_load_balancer.AppLB.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = oci_core_instance.frontend-02.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

output "lb_public_ip" {
  value = [oci_load_balancer.AppLB.ip_address_details]
}
