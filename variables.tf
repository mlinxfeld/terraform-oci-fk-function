variable "tenancy_ocid" {
  description = "Tenancy OCID used for namespace and region discovery."
  type        = string
}

variable "region" {
  description = "OCI region used for provider context and OCIR endpoint resolution."
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment OCID where function resources will be created."
  type        = string
}

variable "ocir_user_name" {
  description = "OCI Registry username used for docker login."
  type        = string
}

variable "ocir_user_password" {
  description = "OCI Registry auth token or password used for docker login."
  type        = string
  sensitive   = true
}

variable "VCN-CIDR" {
  description = "VCN CIDR used only when use_my_fn_network is false."
  type        = string
  default     = "10.0.0.0/16"
}

variable "fnsubnet-CIDR" {
  description = "Subnet CIDR used only when use_my_fn_network is false."
  type        = string
  default     = "10.0.1.0/24"
}

variable "ocir_repo_name" {
  description = "OCI Container Registry repository prefix used for the function image."
  type        = string
  default     = "fkfn"
}

variable "fk_app_name" {
  description = "OCI Functions application name."
  type        = string
  default     = "fkapp"
}

variable "fk_fn_name" {
  description = "OCI Function name."
  type        = string
  default     = "fkfn"
}

variable "fk_fn_version" {
  description = "Function image tag."
  type        = string
  default     = "0.0.1"
}

variable "memory_in_mbs" {
  description = "Memory allocated to the function, in MB."
  type        = number
  default     = 256
}

variable "fk_shape" {
  description = "Functions application shape."
  type        = string
  default     = "GENERIC_ARM"

  validation {
    condition     = contains(["GENERIC_X86_ARM", "GENERIC_X86", "GENERIC_ARM"], var.fk_shape)
    error_message = "fk_shape must be one of: GENERIC_X86_ARM, GENERIC_X86, GENERIC_ARM."
  }
}

variable "invoke_fn" {
  description = "Invoke the function automatically after deployment."
  type        = bool
  default     = false
}

variable "use_my_fn" {
  description = "Inject your own function source files into the embedded function scaffold."
  type        = bool
  default     = false
}

variable "dockerfile_content" {
  description = "Dockerfile content used when use_my_fn is true."
  type        = string
  default     = ""
}

variable "func_py_content" {
  description = "func.py content used when use_my_fn is true."
  type        = string
  default     = ""
}

variable "func_yaml_content" {
  description = "func.yaml content used when use_my_fn is true."
  type        = string
  default     = ""
}

variable "requirements_txt_content" {
  description = "requirements.txt content used when use_my_fn is true."
  type        = string
  default     = ""
}

variable "use_my_fn_network" {
  description = "Use an externally managed subnet instead of creating module-managed networking."
  type        = bool
  default     = false
}

variable "my_fn_subnet_ocid" {
  description = "External subnet OCID used when use_my_fn_network is true."
  type        = string
  default     = ""
}

variable "use_my_fn_app" {
  description = "Attach the function to an externally managed Functions application."
  type        = bool
  default     = false
}

variable "my_fn_app_ocid" {
  description = "External Functions application OCID used when use_my_fn_app is true."
  type        = string
  default     = ""
}

variable "use_oci_logging" {
  description = "Enable OCI Logging for function invocation logs."
  type        = bool
  default     = false
}

variable "oci_logging_group_name" {
  description = "OCI Logging log group name used when use_oci_logging is true."
  type        = string
  default     = "FoggyKitchenFnAppLogGroup"
}

variable "oci_logging_group_description" {
  description = "OCI Logging log group description used when use_oci_logging is true."
  type        = string
  default     = "Foggy Kitchen Fn App Log Group"
}

variable "oci_logging_log_name" {
  description = "OCI Logging log name used when use_oci_logging is true."
  type        = string
  default     = "FoggyKitchenFnAppInvokeLog"
}

variable "fn_config" {
  description = "Optional function configuration map exposed as function environment variables."
  type        = map(string)
  default     = {}
}

variable "fn_timeout_in_seconds" {
  description = "Function timeout in seconds."
  type        = number
  default     = 30
}
