module "oci-fk-custom-function" {
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = var.fn_name
  dockerfile_content       = data.template_file.custom_fn_dockerfile_template.rendered
  func_py_content          = data.template_file.custom_fn_func_py_template.rendered
  func_yaml_content        = data.template_file.custom_fn_func_yaml_template.rendered
  requirements_txt_content = data.template_file.requirements_txt_content.rendered
  invoke_fn                = true
}
