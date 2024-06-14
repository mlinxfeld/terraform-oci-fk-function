variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "ocir_user_name" {}
variable "ocir_user_password" {}

variable "fncustom1_message" {
  default = "Here is function fncustom1!"
}

variable "fncustom2_message" {
  default = "Here is function fncustom2!"
}

variable "httpx_ports" {
  default = ["80", "443"]
}