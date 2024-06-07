variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}

variable "ocir_user_name" {}
variable "ocir_user_password" {}

variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "fnsubnet-CIDR" {
  default = "10.0.1.0/24"
}

variable "ocir_repo_name" {
  default = "fkfn"
}

variable "fk_app_name" {
  default = "fkapp"
}

variable "fk_fn_name" {
  default = "fkfn"
}

variable "fk_fn_version" {
  default = "0.0.1" 
}

variable "memory_in_mbs" {
  default = "256"
}

variable "fk_shape" {
  default = "GENERIC_ARM" # GENERIC_X86_ARM or GENERIC_X86 or GENERIC_ARM
}

variable "invoke_fn" {
  default = false
}

variable "use_my_fn" {
  default = false
}

variable "dockerfile_content" {
  default = ""
}

variable "func_py_content" {
  default = ""
}

variable "func_yaml_content" {
  default = ""
}

variable "requirements_txt_content" {
  default = ""
}

variable "use_my_fn_network" {
  default = false
}

variable "my_fn_subnet_ocid" {
  default = ""
}