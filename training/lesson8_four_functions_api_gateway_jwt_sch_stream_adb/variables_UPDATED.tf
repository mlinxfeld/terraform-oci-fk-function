variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "ocir_user_name" {}
variable "ocir_user_password" {}

variable "fn_custom_message" {
  default = "Custom message!"
}

variable "fn_name" {
  default = "fncustom"
}

variable "httpx_ports" {
  default = ["80", "443"]
}

variable "fn_debug_mode" {
  default = true
}

variable "adb_database_db_name" {
  default = "FoggyKitchenADB"
}
variable "adb_admin_password" {}

variable "adb_app_user_name" {
  default = "APPUSER"
}

variable "adb_app_user_password" {}

variable "adb_sqlnet_alias" {
  default = "foggykitchenadb_medium"
}

variable "fn_jwt_token" {
  default = "ABCD1234"
}