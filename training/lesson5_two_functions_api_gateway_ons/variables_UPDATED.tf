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