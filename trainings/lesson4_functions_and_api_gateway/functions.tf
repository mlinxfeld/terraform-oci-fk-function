
module "oci-fk-custom-function-1" {
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = "fncustom1"
  dockerfile_content       = data.template_file.custom_fn_dockerfile_template.rendered
  func_py_content          = data.template_file.custom_fn_func_py_template1.rendered
  func_yaml_content        = data.template_file.custom_fn_func_yaml_template1.rendered
  requirements_txt_content = data.template_file.requirements_txt_content.rendered
  invoke_fn                = false
  use_oci_logging          = true
  use_my_fn_network        = true
  my_fn_subnet_ocid        = oci_core_subnet.FoggyKitchenPrivateSubnet.id
}

module "oci-fk-custom-function-2" {
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = "fncustom2"
  dockerfile_content       = data.template_file.custom_fn_dockerfile_template.rendered
  func_py_content          = data.template_file.custom_fn_func_py_template2.rendered
  func_yaml_content        = data.template_file.custom_fn_func_yaml_template2.rendered
  requirements_txt_content = data.template_file.requirements_txt_content.rendered
  invoke_fn                = false
  use_oci_logging          = false
  use_my_fn_app            = true
  my_fn_app_ocid           = module.oci-fk-custom-function-1.oci_app_fn.fn_app_ocid
  use_my_fn_network        = true
  my_fn_subnet_ocid        = oci_core_subnet.FoggyKitchenPrivateSubnet.id
}
