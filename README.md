# terraform-oci-fk-function

These is Terraform module that deploys [OCI Function](https://www.oracle.com/cloud/cloud-native/functions/) on [Oracle Cloud Infrastructure (OCI)](https://cloud.oracle.com/en_US/cloud-infrastructure).

## About
Oracle Cloud Infrastructure (OCI) Functions is a serverless compute service that enables developers to create, run, and scale applications without the need to manage any underlying infrastructure. It offers seamless integrations with other Oracle Cloud Infrastructure services and various SaaS applications. Built on the open source Fn Project, OCI Functions allows developers to create applications that are easily portable across different cloud environments and on-premises setups. Functions are designed to execute short-lived, stateless code, performing specific logic tasks. With OCI Functions, customers are billed only for the resources they consume, ensuring cost-effective and efficient application deployment.

## Prerequisites
1. Download and install Terraform (v1.0 or later)
2. Download and install the OCI Terraform Provider (v4.4.0 or later)
3. Export OCI credentials. (this refer to the https://github.com/oracle/terraform-provider-oci )


## What's a Module?
A Module is a canonical, reusable, best-practices definition for how to run a single piece of infrastructure, such as a database or server cluster. Each Module is created using Terraform, and includes automated tests, examples, and documentation. It is maintained both by the open source community and companies that provide commercial support.
Instead of figuring out the details of how to run a piece of infrastructure from scratch, you can reuse existing code that has been proven in production. And instead of maintaining all that infrastructure code yourself, you can leverage the work of the Module community to pick up infrastructure improvements through a version number bump.

## How to use this Module
Each Module has the following folder structure:
* [root](): This folder contains a root module.
* [training](training): This folder contains self-study training how to use the module.
    
To deploy function using this Module with minimal effort use this:

```hcl
module "oci-fk-function" {
  source                   = "github.com/mlinxfeld/terraform-oci-fk-function"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  ocir_user_name           = var.ocir_user_name
  ocir_user_password       = var.ocir_user_password
  compartment_ocid         = var.compartment_ocid
  use_my_fn                = true
  fk_fn_name               = "fncustom"
  dockerfile_content       = data.local_file.fncustom_dockerfile.content
  func_py_content          = data.local_file.fncustom_func_py.content
  func_yaml_content        = data.local_file.fncustom_func_yaml.content
  requirements_txt_content = data.local_file.fncustom_requirements_txt.content
  use_oci_logging          = true
  invoke_fn                = false
}

```

Argument | Description
--- | ---
compartment_ocid | Compartment's OCID where function will be created.
region | Region where function will be created.
ocir_user_name | OCI Registry user name.
ocir_user_password | OCI Registry user password (auth token).
ocir_repo_name | OCI Registry Repository Name.
VCN-CIDR | VCN CIDR for network created inside the module (use_my_fn_network=false).
fnsubnet-CIDR | Subnet CIDR for the Subnet created inside the module (use_my_fn_network=false).
fk_app_name | Name of OCI Application.
fk_fn_name | Name of OCI Function.
fk_fn_version | Version of OCI Function.
memory_in_mbs | Memory in megabytes allocated to Function.
fn_timeout_in_seconds | Function timeout in seconds.
fk_shape | Shape of the Function (GENERIC_X86_ARM or GENERIC_X86 or GENERIC_ARM).
invoke_fn | Flag for invoking the function from the module.
use_my_fn | Flag for declaring your own/custom function.
dockerfile_content | when use_my_fn=True you can inject the content of your custom Dockerfile file.
func_py_content | when use_my_fn=True you can inject the content of your func.py file.
func_yaml_content | when use_my_fn=True you can inject the content of your func.yaml file.
requirements_txt_content | when use_my_fn=True you can inject the content of your requirements.txt file.
use_my_fn_network | Flag for using external networking injected into the module. 
my_fn_subnet_ocid | OCID of the the function subnet (use_my_fn_network=true).
use_my_fn_app | Flag for using external application and associate it with the function created by the module.
my_fn_app_ocid | OCID of the external application (use_my_fn_app=true).
use_oci_logging | Flag for enabling OCI Logging for the Application.
oci_logging_group_name | Name of the OCI Logging Group for the Application.
oci_logging_group_description | Description of the OCI Logging Group for the Application.
oci_logging_log_name | Name of the OCI Logging Log for the Application.
fn_config | Optional config of the function including key-value list for function environment. 


## Contributing
This project is open source. Please submit your contributions by forking this repository and submitting a pull request! FoggyKitchen appreciates any contributions that are made by the open source community.

## License
Copyright (c) 2024 FoggyKitchen.com

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE) for more details.
