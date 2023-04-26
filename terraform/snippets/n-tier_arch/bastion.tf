resource "oci_core_instance" "bastion-01" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "bastion-01"
  shape               = var.ComputeShape
  subnet_id           = oci_core_subnet.Bastion-Subnet1.id
  hostname_label      = "bastion-01"

  shape_config {
    ocpus         = lookup(var.ComputeShapeOCPU, var.EnvType)
    memory_in_gbs = lookup(var.ComputeShapeMem, var.EnvType)
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OL87ImageOCID.images[0], "id")
  }
}

output "BastionPublicIPs" {
  value = [oci_core_instance.bastion-01.*.public_ip]
}
