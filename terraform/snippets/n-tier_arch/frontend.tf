resource "oci_core_instance" "frontend-01" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "frontend-01"
  shape               = "${lookup(var.ComputeShape, var.EnvType)}"
  subnet_id           = "${oci_core_subnet.fe-sub.id}"
  hostname_label      = "frontend-01"

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(var.user-data)}"
  }

  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.OL76ImageOCID.images[0], "id")}"
  }
}

resource "oci_core_instance" "frontend-02" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "frontend-02"
  shape               = "${lookup(var.ComputeShape, var.EnvType)}"
  subnet_id           = "${oci_core_subnet.fe-sub.id}"
  hostname_label      = "frontend-02"

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(var.user-data)}"
  }

  source_details {
    source_type = "image"
    source_id   = "${lookup(data.oci_core_images.OL76ImageOCID.images[0], "id")}"
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
echo '<h2>'
hostname >> /var/www/html/index.html
echo '</h2>'
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
