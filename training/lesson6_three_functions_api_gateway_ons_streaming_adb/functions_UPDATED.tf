module "oci-fk-initiator-function" {
  source                   = "git::https://github.com/foggykitchen/terraform-oci-fk-function.git?ref=update-2026"
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
  my_fn_subnet_ocid        = module.fk_vcn.subnet_ids["functions_private"]
  fn_config = {
    DEBUG_MODE      = tostring(var.fn_debug_mode)
    TOPIC_OCID      = module.fk_ons.topic_id
    STREAM_OCID     = module.fk_streaming.stream_ids["iot_data"]
    STREAM_ENDPOINT = module.fk_streaming.stream_pool_endpoint_fqdn
  }

  depends_on = [module.fk_policy_function_dataflow]
}

module "oci-fk-collector-function" {
  source                   = "git::https://github.com/foggykitchen/terraform-oci-fk-function.git?ref=update-2026"
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
  extra_files = {
    "adb_wallet.b64" = module.oci-fk-adb.adb_database.adb_wallet_content
  }
  invoke_fn                = false
  use_oci_logging          = false
  use_my_fn_app            = true
  my_fn_app_ocid           = module.oci-fk-initiator-function.oci_app_fn.fn_app_ocid
  use_my_fn_network        = true
  my_fn_subnet_ocid        = module.fk_vcn.subnet_ids["functions_private"]
  fn_timeout_in_seconds    = 300
  fn_config = {
    DEBUG_MODE            = tostring(var.fn_debug_mode)
    STREAM_OCID           = module.fk_streaming.stream_ids["iot_data"]
    STREAM_ENDPOINT       = module.fk_streaming.stream_pool_endpoint_fqdn
    ADB_OCID              = module.oci-fk-adb.adb_database.adb_database_id
    ADB_APP_USER_NAME     = var.adb_app_user_name
    ADB_APP_USER_PASSWORD = var.adb_app_user_password
    ADB_SQLNET_ALIAS      = var.adb_sqlnet_alias
    ADB_WALLET_PASSWORD   = module.oci-fk-adb.adb_database.adb_wallet_password
  }

  depends_on = [
    module.oci-fk-adb,
    module.fk_policy_function_dataflow
  ]
}

module "oci-fk-adb-setup-function" {
  source                   = "git::https://github.com/foggykitchen/terraform-oci-fk-function.git?ref=update-2026"
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
  extra_files = {
    "adb_wallet.b64" = module.oci-fk-adb.adb_database.adb_wallet_content
  }
  invoke_fn                = true
  use_oci_logging          = false
  use_my_fn_app            = true
  my_fn_app_ocid           = module.oci-fk-initiator-function.oci_app_fn.fn_app_ocid
  use_my_fn_network        = true
  my_fn_subnet_ocid        = module.fk_vcn.subnet_ids["functions_private"]
  fn_timeout_in_seconds    = 300
  fn_config = {
    DEBUG_MODE            = tostring(var.fn_debug_mode)
    ADB_OCID              = module.oci-fk-adb.adb_database.adb_database_id
    ADB_ADMIN_PASSWORD    = var.adb_admin_password
    ADB_APP_USER_NAME     = var.adb_app_user_name
    ADB_APP_USER_PASSWORD = var.adb_app_user_password
    ADB_SQLNET_ALIAS      = var.adb_sqlnet_alias
    ADB_WALLET_PASSWORD   = module.oci-fk-adb.adb_database.adb_wallet_password
  }

  depends_on = [
    module.oci-fk-adb,
    module.fk_policy_function_dataflow
  ]
}
