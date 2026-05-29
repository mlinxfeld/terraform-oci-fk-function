# terraform-oci-fk-function

This repository contains a reusable **Terraform / OpenTofu module** and progressive training examples for deploying **Oracle Cloud Infrastructure (OCI) Functions** on **Oracle Cloud Infrastructure (OCI)**.

It is part of the [FoggyKitchen.com](https://foggykitchen.com) training ecosystem and is designed as a composable starting point for OCI Functions scenarios that can later be combined with API Gateway, Notifications, Streaming, Service Connector Hub, Logging, and database-backed workflows.

---

## Purpose

The goal of this module is to provide a reusable reference implementation for OCI Functions:

- OCI Functions application provisioning
- OCI Function provisioning
- OCI Container Registry repository creation
- Function image build and push workflow through `fn build` and `docker push`
- Optional function invocation after deployment
- Optional OCI Logging integration for function invocation logs
- Optional module-managed networking for simple function application scenarios

This is not a full event-driven application platform. API Gateway, Notifications, Streaming, Service Connector Hub, Object Storage event flows, and database integration belong either in dedicated modules or in lesson-specific compositions.

---

## What the module does

Depending on the configuration, the module can create:

- OCI Functions application
- OCI Function
- OCI Container Registry repository for the function image
- Optional OCI Logging log group and service log for function invocation logs
- Optional VCN, subnet, route table, internet gateway, and DHCP options for a simple module-managed network
- Optional local function invocation after deployment

The module intentionally does not create:

- API Gateway resources
- Notifications resources
- Streaming resources
- Service Connector Hub resources
- Object Storage event pipelines
- IAM policies for external services

Those concerns belong in dedicated modules or training lesson compositions.

---

## Repository Structure

```bash
terraform-oci-fk-function/
├── README.md
├── LICENSE
├── datasources.tf
├── locals.tf
├── function.tf
├── fn_build_push.tf
├── fn_invoke.tf
├── logging.tf
├── network.tf
├── outputs.tf
├── variables.tf
├── versions.tf
├── functions/
│   └── fkFn/
│       ├── Dockerfile
│       ├── func.py
│       ├── func.yaml
│       └── requirements.txt
└── training/
    ├── README.md
    ├── lesson1_hello_world_function/
    ├── lesson2_custom_function/
    ├── lesson3_two_functions_under_one_app/
    ├── lesson4_two_functions_api_gateway/
    ├── lesson5_two_functions_api_gateway_ons/
    ├── lesson6_three_functions_api_gateway_ons_streaming_adb/
    ├── lesson7_three_functions_api_gateway_sch_stream_adb/
    ├── lesson8_four_functions_api_gateway_jwt_sch_stream_adb/
    └── lesson9_five_functions_api_gateway_jwt_sch_stream_adb_bucket_event/
```

Each lesson folder is runnable on its own and extends the same function foundation toward broader OCI integration scenarios.

---

## Example Usage

```hcl
module "function" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-function.git"

  tenancy_ocid       = var.tenancy_ocid
  compartment_ocid   = var.compartment_ocid
  region             = var.region
  ocir_user_name     = var.ocir_user_name
  ocir_user_password = var.ocir_user_password

  fk_app_name    = "fkapp"
  fk_fn_name     = "fncustom"
  ocir_repo_name = "fkfn"

  use_my_fn                = true
  dockerfile_content       = data.local_file.fncustom_dockerfile.content
  func_py_content          = data.local_file.fncustom_func_py.content
  func_yaml_content        = data.local_file.fncustom_func_yaml.content
  requirements_txt_content = data.local_file.fncustom_requirements_txt.content

  use_my_fn_network = true
  my_fn_subnet_ocid = var.function_subnet_ocid

  use_oci_logging = true
  invoke_fn       = false
}
```

---

## Inputs

Key inputs exposed by the module:

- `tenancy_ocid`: tenancy OCID used for OCI namespace and region discovery
- `compartment_ocid`: compartment where function resources are created
- `region`: OCI region used for provider context and OCIR endpoint resolution
- `ocir_user_name`: OCI Registry username
- `ocir_user_password`: OCI Registry auth token or password
- `ocir_repo_name`: OCI Registry repository prefix used for function images
- `fk_app_name`: Functions application name
- `fk_fn_name`: function name
- `fk_fn_version`: function image tag
- `memory_in_mbs`: function memory size in MB
- `fn_timeout_in_seconds`: function timeout in seconds
- `fk_shape`: Functions application shape
- `use_my_fn`: inject your own function source files into the embedded `functions/fkFn` scaffold
- `use_my_fn_network`: inject an external subnet instead of creating module-managed networking
- `my_fn_subnet_ocid`: external subnet OCID used when `use_my_fn_network = true`
- `use_my_fn_app`: attach the function to an externally managed Functions application
- `my_fn_app_ocid`: external Functions application OCID used when `use_my_fn_app = true`
- `use_oci_logging`: enable OCI Logging for function invocation logs
- `invoke_fn`: invoke the function automatically after deployment
- `fn_config`: optional function configuration map

The full variable contract is defined in [variables.tf](/Users/mlinxfeld/codes/github/terraform-oci-fk-function/variables.tf).

---

## Outputs

The module exports:

- `oci_app_fn.fn_app_ocid`: Functions application OCID
- `oci_app_fn.fn_ocid`: function OCID
- `oci_app_fn.fn_subnet_ocid`: subnet OCID associated with the function application

The exact output contract is defined in [outputs.tf](/Users/mlinxfeld/codes/github/terraform-oci-fk-function/outputs.tf).

---

## Design Principles

- The root module stays focused on the OCI Functions application and function lifecycle
- More advanced event-driven integrations should stay explicit instead of being hidden inside one module
- Training lessons can build on the root module, but each lesson remains runnable on its own
- Root-level networking and logging are treated as convenience capabilities, not the final 2026 architecture standard

---

## Notes

- The current root module still manages basic networking and logging with raw OCI resources.
- The current root module still embeds build, push, and invoke workflows through local execution.
- The 2026 modernization path for this repository will likely extract API Gateway, Notifications, Streaming, and Service Connector Hub into dedicated modules.

---

## Related Resources

- [Training examples](training)
- [FoggyKitchen.com](https://foggykitchen.com/)

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.
See [LICENSE](LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
