
module "oci-fk-initiator-function-1" {
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = "fninitiator"
  dockerfile_content       = data.local_file.fninitiator_dockerfile.rendered
  func_py_content          = data.local_file.fninitiator_func_py.rendered
  func_yaml_content        = data.local_file.fninitiator_func_yaml.rendered
  requirements_txt_content = data.local_file.fninitiator_requirements_txt.rendered
  invoke_fn                = false
  use_oci_logging          = true
  use_my_fn_network        = true
  my_fn_subnet_ocid        = oci_core_subnet.FoggyKitchenPrivateSubnet.id
  fn_config                = {"TOPIC_OCID" : "${oci_ons_notification_topic.FoggyKitchenTopic.id}"}
}

module "oci-fk-collector-function-2" {
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = "fncollector"
  dockerfile_content       = data.local_file.fncollector_dockerfile.rendered
  func_py_content          = data.local_file.fncollector_func_py.rendered
  func_yaml_content        = data.local_file.fncollector_func_yaml.rendered
  requirements_txt_content = data.local_file.fncollector_requirements_txt.rendered
  invoke_fn                = false
  use_oci_logging          = false
  use_my_fn_app            = true
  my_fn_app_ocid           = module.oci-fk-custom-function-1.oci_app_fn.fn_app_ocid
  use_my_fn_network        = true
  my_fn_subnet_ocid        = oci_core_subnet.FoggyKitchenPrivateSubnet.id
}
