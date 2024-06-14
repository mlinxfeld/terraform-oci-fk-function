module "oci-fk-custom-function" {
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = "fncustom"
  dockerfile_content       = data.local_file.fncustom_dockerfile.content
  func_py_content          = data.local_file.fncustom_func_py.content
  func_yaml_content        = data.local_file.fncustom_func_yaml.content
  requirements_txt_content = data.local_file.fncustom_requirements_txt.content
  use_oci_logging          = true
  invoke_fn                = true
  fn_config                = {"FN_CUSTOM_MESSAGE" : "${var.fn_custom_message}"}
}
