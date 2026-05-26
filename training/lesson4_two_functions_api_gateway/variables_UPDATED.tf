variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_ocid" {
  description = "OCI compartment OCID used for lesson4 resources."
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

variable "fncustom1_message" {
  description = "Custom message returned by fncustom1."
  type        = string
  default     = "Here is function fncustom1!"
}

variable "fncustom2_message" {
  description = "Custom message returned by fncustom2."
  type        = string
  default     = "Here is function fncustom2!"
}

variable "httpx_ports" {
  description = "Public listener ports opened on the API Gateway subnet security list."
  type        = list(number)
  default     = [80, 443]
}
