provider "oci" {
  tenancy_ocid         = var.tenancy_ocid
  region               = var.region
  disable_auto_retries = "true"

  # Not required for Resource Manager
  # Uncomment and assign values when using Cloud Shell or local Terraform install

  # user_ocid            = var.user_ocid
  # fingerprint          = var.fingerprint
  # private_key_path     = var.private_key_path
}

