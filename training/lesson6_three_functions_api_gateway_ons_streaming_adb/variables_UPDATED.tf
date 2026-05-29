variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_ocid" {
  description = "OCI compartment OCID used for lesson6 resources."
  type        = string
}

variable "user_ocid" {
  description = "OCI user OCID."
  type        = string
}

variable "fingerprint" {
  description = "OCI API key fingerprint."
  type        = string
}

variable "private_key_path" {
  description = "Path to the OCI API private key."
  type        = string
}

variable "region" {
  description = "OCI region used for the deployment."
  type        = string
}

variable "ocir_user_name" {
  description = "OCI Registry user name used for docker login and function image push."
  type        = string
}

variable "ocir_user_password" {
  description = "OCI Registry auth token used for docker login and function image push."
  type        = string
  sensitive   = true
}

variable "httpx_ports" {
  description = "Public listener ports opened on the API Gateway subnet security list."
  type        = list(number)
  default     = [80, 443]
}

variable "fn_debug_mode" {
  description = "Whether lesson6 functions should emit additional debug logs."
  type        = bool
  default     = true
}

variable "adb_database_db_name" {
  description = "ADB database name and display name."
  type        = string
  default     = "FoggyKitchenADB"
}

variable "adb_admin_password" {
  description = "ADB ADMIN password used to create the database and bootstrap APPUSER."
  type        = string
  sensitive   = true
}

variable "adb_app_user_name" {
  description = "Application schema created by fnadbsetup."
  type        = string
  default     = "APPUSER"
}

variable "adb_app_user_password" {
  description = "Password for the application schema created by fnadbsetup."
  type        = string
  sensitive   = true
}

variable "adb_sqlnet_alias" {
  description = "ADB SQL*Net alias used by fnadbsetup and fncollector."
  type        = string
  default     = "foggykitchenadb_medium"
}
