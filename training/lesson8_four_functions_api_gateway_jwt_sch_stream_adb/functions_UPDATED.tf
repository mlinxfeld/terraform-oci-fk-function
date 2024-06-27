module "oci-fk-initiator-function" {
  depends_on               = [
    data.local_file.fninitiator_dockerfile,
    data.local_file.fninitiator_func_py,
    data.local_file.fninitiator_func_yaml,
    data.local_file.fninitiator_requirements_txt
  ]  
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = "fninitiator"
  dockerfile_content       = data.local_file.fninitiator_dockerfile.content
  func_py_content          = data.local_file.fninitiator_func_py.content
  func_yaml_content        = data.local_file.fninitiator_func_yaml.content
  requirements_txt_content = data.local_file.fninitiator_requirements_txt.content
  invoke_fn                = false
  use_oci_logging          = true
  use_my_fn_network        = true
  my_fn_subnet_ocid        = oci_core_subnet.FoggyKitchenPrivateSubnet.id
  fn_config                = {
    "DEBUG_MODE"      : "${var.fn_debug_mode}", 
    "STREAM_OCID"     : "${oci_streaming_stream.FoggyKitchenStream.id}", 
    "STREAM_ENDPOINT" : "${data.oci_streaming_stream_pool.FoggyKitchenStreamPool.endpoint_fqdn}"
 }
}

module "oci-fk-collector-function" {
  depends_on               = [
    module.oci-fk-adb,
    data.local_file.fncollector_dockerfile,
    data.local_file.fncollector_func_py,
    data.local_file.fncollector_func_yaml,
    data.local_file.fncollector_requirements_txt
  ]    
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = "fncollector"
  dockerfile_content       = data.local_file.fncollector_dockerfile.content
  func_py_content          = data.local_file.fncollector_func_py.content
  func_yaml_content        = data.local_file.fncollector_func_yaml.content
  requirements_txt_content = data.local_file.fncollector_requirements_txt.content
  invoke_fn                = false
  use_oci_logging          = false
  use_my_fn_app            = true
  my_fn_app_ocid           = module.oci-fk-initiator-function.oci_app_fn.fn_app_ocid
  use_my_fn_network        = true
  my_fn_subnet_ocid        = oci_core_subnet.FoggyKitchenPrivateSubnet.id
  fn_timeout_in_seconds    = 300
  fn_config                = {
    "DEBUG_MODE"            : "${var.fn_debug_mode}", 
    "STREAM_OCID"           : "${oci_streaming_stream.FoggyKitchenStream.id}", 
    "STREAM_ENDPOINT"       : "${data.oci_streaming_stream_pool.FoggyKitchenStreamPool.endpoint_fqdn}",
    "ADB_OCID"              : "${module.oci-fk-adb.adb_database.adb_database_id}"
    "ADB_APP_USER_NAME"     : "${var.adb_app_user_name}", 
    "ADB_APP_USER_PASSWORD" : "${var.adb_app_user_password}", 
    "ADB_SQLNET_ALIAS"      : "${var.adb_sqlnet_alias}"
  }
}

module "oci-fk-adb-setup-function" {
  depends_on               = [
    module.oci-fk-adb,
    data.local_file.fnadbsetup_dockerfile,
    data.local_file.fnadbsetup_func_py,
    data.local_file.fnadbsetup_func_yaml,
    data.local_file.fnadbsetup_requirements_txt
  ]     
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = "fnadbsetup"
  dockerfile_content       = data.local_file.fnadbsetup_dockerfile.content
  func_py_content          = data.local_file.fnadbsetup_func_py.content
  func_yaml_content        = data.local_file.fnadbsetup_func_yaml.content
  requirements_txt_content = data.local_file.fnadbsetup_requirements_txt.content
  invoke_fn                = true
  use_oci_logging          = false
  use_my_fn_app            = true
  my_fn_app_ocid           = module.oci-fk-initiator-function.oci_app_fn.fn_app_ocid
  use_my_fn_network        = true
  my_fn_subnet_ocid        = oci_core_subnet.FoggyKitchenPublicSubnet.id
  fn_config                = {
    "DEBUG_MODE"            : "${var.fn_debug_mode}", 
    "ADB_OCID"              : "${module.oci-fk-adb.adb_database.adb_database_id}"
    "ADB_ADMIN_PASSWORD"    : "${var.adb_admin_password}", 
    "ADB_APP_USER_NAME"     : "${var.adb_app_user_name}", 
    "ADB_APP_USER_PASSWORD" : "${var.adb_app_user_password}", 
    "ADB_SQLNET_ALIAS"      : "${var.adb_sqlnet_alias}"
  }
}

module "oci-fk-jwt-auth-function" {
  depends_on               = [
    data.local_file.fnjwtauth_dockerfile,
    data.local_file.fnjwtauth_func_py,
    data.local_file.fnjwtauth_func_yaml,
    data.local_file.fnjwtauth_requirements_txt
  ]     
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = "fnjwtauth"
  dockerfile_content       = data.local_file.fnjwtauth_dockerfile.content
  func_py_content          = data.local_file.fnjwtauth_func_py.content
  func_yaml_content        = data.local_file.fnjwtauth_func_yaml.content
  requirements_txt_content = data.local_file.fnjwtauth_requirements_txt.content
  invoke_fn                = false
  use_oci_logging          = false
  use_my_fn_app            = true
  my_fn_app_ocid           = module.oci-fk-initiator-function.oci_app_fn.fn_app_ocid
  use_my_fn_network        = true
  my_fn_subnet_ocid        = oci_core_subnet.FoggyKitchenPrivateSubnet.id
  fn_config                = {"FN_JWT_TOKEN" : "${var.fn_jwt_token}"}
}
