module "oci-fk-hello-world-function" {
  source             = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid       = var.tenancy_ocid
  region             = var.region
  ocir_user_name     = var.ocir_user_name
  ocir_user_password = var.ocir_user_password
  compartment_ocid   = var.compartment_ocid
  use_my_fn          = false
  invoke_fn          = true
}
