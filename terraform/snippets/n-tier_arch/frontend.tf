resource "oci_core_instance" "frontend-01" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "frontend-${var.EnvType}-01"
  shape               = var.ComputeShape
  subnet_id           = oci_core_subnet.fe-sub.id
  hostname_label      = "frontend-${var.EnvType}-01"

  shape_config {
    ocpus         = lookup(var.ComputeShapeOCPU, var.EnvType)
    memory_in_gbs = lookup(var.ComputeShapeMem, var.EnvType)
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(var.user-data)}"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OL87ImageOCID.images[0], "id")
  }
}

resource "oci_core_instance" "frontend-02" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "frontend-${var.EnvType}-02"
  shape               = var.ComputeShape
  subnet_id           = oci_core_subnet.fe-sub.id
  hostname_label      = "frontend-${var.EnvType}-02"

  shape_config {
    ocpus         = lookup(var.ComputeShapeOCPU, var.EnvType)
    memory_in_gbs = lookup(var.ComputeShapeMem, var.EnvType)
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = base64encode(var.user-data)
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OL87ImageOCID.images[0], "id")
  }
}

variable "user-data" {
  default = <<EOF
#!/bin/bash -x
echo '################### webserver userdata begins #####################'
touch ~opc/userdata.`date +%s`.start
# echo '########## yum update all ###############'
# yum update -y
echo '########## basic webserver ##############'
yum install -y httpd
systemctl enable  httpd.service
systemctl start  httpd.service
echo '<html><head></head><body><pre><code>' > /var/www/html/index.html
echo "<h2>`hostname`</h2>" >> /var/www/html/index.html
echo '' >> /var/www/html/index.html
cat /etc/os-release >> /var/www/html/index.html
echo '</code></pre></body></html>' >> /var/www/html/index.html
firewall-offline-cmd --add-service=http
systemctl enable  firewalld
systemctl restart  firewalld
touch ~opc/userdata.`date +%s`.finish
echo '################### webserver userdata ends #######################'
EOF
}
