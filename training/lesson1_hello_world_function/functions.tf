module "oci-fk-hello-world-function" {
  source             = "../.."
  tenancy_ocid       = var.tenancy_ocid
  region             = var.region
  ocir_user_name     = var.ocir_user_name
  ocir_user_password = var.ocir_user_password
  compartment_ocid   = var.compartment_ocid
  use_my_fn          = false
  use_my_fn_network  = true
  my_fn_subnet_ocid  = module.fk_vcn.subnet_ids["functions_public"]
  invoke_fn          = true
}
