resource "oci_core_instance" "bastion-01" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "bastion-01"
  shape               = "${lookup(var.ComputeShape, var.EnvType)}"
  subnet_id           = "${oci_core_subnet.Bastion-Subnet1.id}"
  hostname_label      = "bastion-01"

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.OL76ImageOCID.images[0], "id")}"
  }
}

output "BastionPublicIPs" {
  value = ["${oci_core_instance.bastion-01.*.public_ip}"]
}
