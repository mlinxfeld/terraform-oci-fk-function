
# FoggyKitchen OCI Function with Terraform 

## LESSON 2 - Creating Custom Function

In this second lesson, we will create a custom function named `fncustom`. We will again use the `terraform-oci-fk-module`, but this time we will inject four crucial files for the function build:

1. `Dockerfile` - Lists all necessary commands to dockerize the function.
2. `func.py` - Contains the Python code for the function.
3. `func.yaml` - The manifest file for the function.
4. `requirements.txt` - Lists all necessary libraries for the `pip3` utility.

Additionally, we will inject a custom message that the function will respond with when invoked at the end of the Terraform deployment.

![](images/terraform-oci-fk-function-lesson2.png)

## Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/mlinxfeld/terraform-oci-fk-function/releases/latest/download/terraform-oci-fk-function-lesson2.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 

## Deploy Using the Terraform CLI in Cloud Shell

### Clone of the repo into OCI Cloud Shell

Now, you'll want a local copy of this repo. You can make that with the commands:
Clone the repo from github by executing the command as follows and then go to proper subdirectory:

```
martin_lin@codeeditor:~ (eu-frankfurt-1)$ git clone https://github.com/mlinxfeld/terraform-oci-fk-function.git

martin_lin@codeeditor:~ (eu-frankfurt-1)$ cd terraform-oci-fk-function

martin_lin@codeeditor:terraform-oci-fk-adb (eu-frankfurt-1)$ cd training/lesson2_custom_function/
```

### Prerequisites
Create environment file with terraform.tfvars file starting with example file:

```
martin_lin@codeeditor:lesson2_custom_function (eu-frankfurt-1)$ cp terraform.tfvars.example terraform.tfvars

martin_lin@codeeditor:lesson2_custom_function (eu-frankfurt-1)$ vi terraform.tfvars

tenancy_ocid       = "ocid1.tenancy.oc1..<your_tenancy_ocid>"
compartment_ocid   = "ocid1.compartment.oc1..<your_comparment_ocid>"
region             = "<oci_region>"
ocir_user_name     = "<user_name>"
ocir_user_password = "<user_auth_token>"
```

### Initialize Terraform

Run the following command to initialize Terraform environment:

```
martin_lin@codeeditor:lesson2_custom_function (eu-frankfurt-1)$ terraform init 

Initializing the backend...
Upgrading modules...
Downloading git::https://github.com/mlinxfeld/terraform-oci-fk-function.git for oci-fk-custom-function...
- oci-fk-custom-function in .terraform/modules/oci-fk-custom-function

Initializing provider plugins...
- Finding latest version of hashicorp/local...
- Finding latest version of hashicorp/null...
- Finding latest version of hashicorp/oci...
- Using previously-installed hashicorp/local v2.5.1
- Using previously-installed hashicorp/null v3.2.2
- Installing hashicorp/oci v5.46.0...
- Installed hashicorp/oci v5.46.0 (unauthenticated)

Terraform has made some changes to the provider dependency selections recorded
in the .terraform.lock.hcl file. Review those changes and commit them to your
version control system if they represent changes you intended to make.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Apply the changes 

Run the following command for applying changes with the proposed plan:

```
martin_lin@codeeditor:lesson2_custom_function (eu-frankfurt-1)$ terraform apply 

data.local_file.fncustom_dockerfile: Reading...
data.local_file.fncustom_func_yaml: Reading...
data.local_file.fncustom_requirements_txt: Reading...
data.local_file.fncustom_func_py: Reading...
data.local_file.fncustom_requirements_txt: Read complete after 0s [id=91bd32a35ac20833294303bda57f32b4c1692a09]
data.local_file.fncustom_func_py: Read complete after 0s [id=871fae224158a4fdc178b10d9f52b88d58c484c1]
data.local_file.fncustom_dockerfile: Read complete after 0s [id=aa3833301ffe31669490f8269952e79a0989b142]
data.local_file.fncustom_func_yaml: Read complete after 0s [id=8edf769e8713b427e6660888240ca0d0d39c7d88]
module.oci-fk-custom-function.data.oci_identity_regions.oci_regions: Reading...
module.oci-fk-custom-function.data.oci_objectstorage_namespace.os_namespace: Reading...
module.oci-fk-custom-function.data.oci_identity_regions.oci_regions: Read complete after 0s [id=IdentityRegionsDataSource-0]
module.oci-fk-custom-function.data.oci_objectstorage_namespace.os_namespace: Read complete after 0s [id=ObjectStorageNamespaceDataSource-3596290162]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.oci-fk-custom-function.local_file.dockerfile_content[0] will be created
  + resource "local_file" "dockerfile_content" {
      + content              = <<-EOT
            FROM oraclelinux:8-slim as ol8
            
            RUN microdnf install -y wget \
                tar \
                gzip \
                which 
            
            FROM fnproject/python:3.8.5-dev as build-stage
            
            WORKDIR /function
            
            ADD requirements.txt /function/
            
            RUN pip3 install --target /python/  --no-cache --no-cache-dir -r requirements.txt && \                       
                rm -fr ~/.cache/pip /tmp* requirements.txt func.yaml Dockerfile .venv
            
            ADD . /function/
            
            RUN rm -fr /function/.pip_cache
            
            FROM fnproject/python:3.8.5
            
            WORKDIR /function
            
            COPY --from=build-stage /function /function
            
            COPY --from=build-stage /python /python
            
            ENV PYTHONPATH=/python
            
            ENTRYPOINT ["/python/bin/fdk", "/function/func.py", "handler"]
        EOT
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = ".terraform/modules/oci-fk-custom-function/functions/fkFn/Dockerfile"
      + id                   = (known after apply)
    }

  # module.oci-fk-custom-function.local_file.func_py_content[0] will be created
  + resource "local_file" "func_py_content" {
      + content              = <<-EOT
            import io
            import os
            import json
            import logging
            from fdk import response
            
            
            def handler(ctx, data: io.BytesIO=None):
            
                if os.getenv("FN_CUSTOM_MESSAGE") != None:
                    fn_custom_message = os.getenv("FN_CUSTOM_MESSAGE")
                else:
                    _='Missing configuration key FN_CUSTOM_MESSAGE'
                    logging.getLogger().error(_)
                    return None, _
            
                logging.getLogger().info(f'Starting function with message: {fn_custom_message}')
            
                return response.Response(
                    ctx, response_data=json.dumps(
                        {"message": fn_custom_message}),
                    headers={"Content-Type": "application/json"}
                )
        EOT
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = ".terraform/modules/oci-fk-custom-function/functions/fkFn/func.py"
      + id                   = (known after apply)
    }

  # module.oci-fk-custom-function.local_file.func_yaml_content[0] will be created
  + resource "local_file" "func_yaml_content" {
      + content              = <<-EOT
            schema_version: 20180708
            name: fncustom
            version: 0.0.1
            runtime: docker
            entrypoint: /python/bin/fdk /function/func.py handler
            memory: 256
        EOT
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = ".terraform/modules/oci-fk-custom-function/functions/fkFn/func.yaml"
      + id                   = (known after apply)
    }

  # module.oci-fk-custom-function.local_file.requirements_txt_content[0] will be created
  + resource "local_file" "requirements_txt_content" {
      + content              = <<-EOT
            fdk
            oci
        EOT
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = ".terraform/modules/oci-fk-custom-function/functions/fkFn/requirements.txt"
      + id                   = (known after apply)
    }

  # module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] will be created
  + resource "null_resource" "FoggyKitchenFnInvoke" {
      + id = (known after apply)
    }

  # module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] will be created
  + resource "null_resource" "FoggyKitchenMyFnSetup" {
      + id = (known after apply)
    }

  # module.oci-fk-custom-function.oci_artifacts_container_repository.FoggyKitchenOCIR will be created
  + resource "oci_artifacts_container_repository" "FoggyKitchenOCIR" {
      + billable_size_in_gbs = (known after apply)
      + compartment_id       = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa"
      + created_by           = (known after apply)
      + defined_tags         = (known after apply)
      + display_name         = "fkfn/fncustom"
      + freeform_tags        = (known after apply)
      + id                   = (known after apply)
      + image_count          = (known after apply)
      + is_immutable         = (known after apply)
      + is_public            = false
      + layer_count          = (known after apply)
      + layers_size_in_bytes = (known after apply)
      + namespace            = (known after apply)
      + state                = (known after apply)
      + system_tags          = (known after apply)
      + time_created         = (known after apply)
      + time_last_pushed     = (known after apply)
    }

  # module.oci-fk-custom-function.oci_core_dhcp_options.FoggyKitchenDhcpOptions1[0] will be created
  + resource "oci_core_dhcp_options" "FoggyKitchenDhcpOptions1" {
      + compartment_id   = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa"
      + defined_tags     = (known after apply)
      + display_name     = "FoggyKitchenDHCPOptions1"
      + domain_name_type = (known after apply)
      + freeform_tags    = (known after apply)
      + id               = (known after apply)
      + state            = (known after apply)
      + time_created     = (known after apply)
      + vcn_id           = (known after apply)

      + options {
          + custom_dns_servers  = []
          + search_domain_names = (known after apply)
          + server_type         = "VcnLocalPlusInternet"
          + type                = "DomainNameServer"
        }
      + options {
          + custom_dns_servers  = []
          + search_domain_names = [
              + "foggykitchen.com",
            ]
          + server_type         = (known after apply)
          + type                = "SearchDomain"
        }
    }

  # module.oci-fk-custom-function.oci_core_internet_gateway.FoggyKitchenInternetGateway[0] will be created
  + resource "oci_core_internet_gateway" "FoggyKitchenInternetGateway" {
      + compartment_id = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa"
      + defined_tags   = (known after apply)
      + display_name   = "FoggyKitchenInternetGateway"
      + enabled        = true
      + freeform_tags  = (known after apply)
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + state          = (known after apply)
      + time_created   = (known after apply)
      + vcn_id         = (known after apply)
    }

  # module.oci-fk-custom-function.oci_core_route_table.FoggyKitchenRouteTableViaIGW[0] will be created
  + resource "oci_core_route_table" "FoggyKitchenRouteTableViaIGW" {
      + compartment_id = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa"
      + defined_tags   = (known after apply)
      + display_name   = "FoggyKitchenRouteTableViaIGW"
      + freeform_tags  = (known after apply)
      + id             = (known after apply)
      + state          = (known after apply)
      + time_created   = (known after apply)
      + vcn_id         = (known after apply)

      + route_rules {
          + cidr_block        = (known after apply)
          + description       = (known after apply)
          + destination       = "0.0.0.0/0"
          + destination_type  = "CIDR_BLOCK"
          + network_entity_id = (known after apply)
          + route_type        = (known after apply)
        }
    }

  # module.oci-fk-custom-function.oci_core_subnet.FoggyKitchenPublicSubnet[0] will be created
  + resource "oci_core_subnet" "FoggyKitchenPublicSubnet" {
      + availability_domain        = (known after apply)
      + cidr_block                 = "10.0.1.0/24"
      + compartment_id             = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa"
      + defined_tags               = (known after apply)
      + dhcp_options_id            = (known after apply)
      + display_name               = "FoggyKitchenPublicSubnet"
      + dns_label                  = "FoggyKitchenN1"
      + freeform_tags              = (known after apply)
      + id                         = (known after apply)
      + ipv6cidr_block             = (known after apply)
      + ipv6cidr_blocks            = (known after apply)
      + ipv6virtual_router_ip      = (known after apply)
      + prohibit_internet_ingress  = (known after apply)
      + prohibit_public_ip_on_vnic = (known after apply)
      + route_table_id             = (known after apply)
      + security_list_ids          = (known after apply)
      + state                      = (known after apply)
      + subnet_domain_name         = (known after apply)
      + time_created               = (known after apply)
      + vcn_id                     = (known after apply)
      + virtual_router_ip          = (known after apply)
      + virtual_router_mac         = (known after apply)
    }

  # module.oci-fk-custom-function.oci_core_virtual_network.FoggyKitchenVCN[0] will be created
  + resource "oci_core_virtual_network" "FoggyKitchenVCN" {
      + byoipv6cidr_blocks               = (known after apply)
      + cidr_block                       = "10.0.0.0/16"
      + cidr_blocks                      = (known after apply)
      + compartment_id                   = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa"
      + default_dhcp_options_id          = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_list_id         = (known after apply)
      + defined_tags                     = (known after apply)
      + display_name                     = "FoggyKitchenVCN"
      + dns_label                        = "FoggyKitchenVCN"
      + freeform_tags                    = (known after apply)
      + id                               = (known after apply)
      + ipv6cidr_blocks                  = (known after apply)
      + ipv6private_cidr_blocks          = (known after apply)
      + is_ipv6enabled                   = (known after apply)
      + is_oracle_gua_allocation_enabled = (known after apply)
      + state                            = (known after apply)
      + time_created                     = (known after apply)
      + vcn_domain_name                  = (known after apply)
    }

  # module.oci-fk-custom-function.oci_functions_application.FoggyKitchenFnApp[0] will be created
  + resource "oci_functions_application" "FoggyKitchenFnApp" {
      + compartment_id             = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa"
      + config                     = (known after apply)
      + defined_tags               = (known after apply)
      + display_name               = "fkapp"
      + freeform_tags              = (known after apply)
      + id                         = (known after apply)
      + network_security_group_ids = (known after apply)
      + shape                      = "GENERIC_ARM"
      + state                      = (known after apply)
      + subnet_ids                 = (known after apply)
      + syslog_url                 = (known after apply)
      + time_created               = (known after apply)
      + time_updated               = (known after apply)
    }

  # module.oci-fk-custom-function.oci_functions_function.FoggyKitchenFn will be created
  + resource "oci_functions_function" "FoggyKitchenFn" {
      + application_id     = (known after apply)
      + compartment_id     = (known after apply)
      + config             = {
          + "FN_CUSTOM_MESSAGE" = "Here is custom message!"
        }
      + defined_tags       = (known after apply)
      + display_name       = "fncustom"
      + freeform_tags      = (known after apply)
      + id                 = (known after apply)
      + image              = "fra.ocir.io/fr5tvfiq2xhq/fkfn/fncustom:0.0.1"
      + image_digest       = (known after apply)
      + invoke_endpoint    = (known after apply)
      + memory_in_mbs      = "256"
      + shape              = (known after apply)
      + state              = (known after apply)
      + time_created       = (known after apply)
      + time_updated       = (known after apply)
      + timeout_in_seconds = 30
    }

  # module.oci-fk-custom-function.oci_logging_log.FoggyKitchenFnAppInvokeLog[0] will be created
  + resource "oci_logging_log" "FoggyKitchenFnAppInvokeLog" {
      + compartment_id     = (known after apply)
      + defined_tags       = (known after apply)
      + display_name       = "FoggyKitchenFnAppInvokeLog"
      + freeform_tags      = (known after apply)
      + id                 = (known after apply)
      + is_enabled         = true
      + log_group_id       = (known after apply)
      + log_type           = "SERVICE"
      + retention_duration = (known after apply)
      + state              = (known after apply)
      + tenancy_id         = (known after apply)
      + time_created       = (known after apply)
      + time_last_modified = (known after apply)

      + configuration {
          + compartment_id = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa"

          + source {
              + category    = "invoke"
              + parameters  = (known after apply)
              + resource    = (known after apply)
              + service     = "functions"
              + source_type = "OCISERVICE"
            }
        }
    }

  # module.oci-fk-custom-function.oci_logging_log_group.FoggyKitchenFnAppLogGroup[0] will be created
  + resource "oci_logging_log_group" "FoggyKitchenFnAppLogGroup" {
      + compartment_id     = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa"
      + defined_tags       = (known after apply)
      + description        = "Foggy Kitchen Fn App Log Group"
      + display_name       = "FoggyKitchenFnAppLogGroup"
      + freeform_tags      = (known after apply)
      + id                 = (known after apply)
      + state              = (known after apply)
      + time_created       = (known after apply)
      + time_last_modified = (known after apply)
    }

Plan: 16 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

(...)

module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): .
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): .
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): .
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): .
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): .

module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): Function fncustom:0.0.1 built successfully.
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0]: Provisioning with 'local-exec'...
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): Executing: ["/bin/sh" "-c" "image=$(docker images | grep fncustom | awk -F ' ' '{print $3}') ; docker tag $image fra.ocir.io/fr5tvfiq2xhq/fkfn/fncustom:0.0.1"]
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0]: Provisioning with 'local-exec'...
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): Executing: ["/bin/sh" "-c" "docker push fra.ocir.io/fr5tvfiq2xhq/fkfn/fncustom:0.0.1"]
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): The push refers to repository [fra.ocir.io/fr5tvfiq2xhq/fkfn/fncustom]
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 710f14e8d0f7: Preparing
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 936f98862a75: Preparing
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 93621bd20a35: Preparing
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 4652f1ecdb19: Preparing
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): c9236a9b8b93: Preparing
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 1986fa667ad1: Preparing
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 47da4524d17f: Preparing
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): a8ba81d08a13: Preparing
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): bd0287fb57f4: Preparing
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): e829239188f8: Preparing
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 1986fa667ad1: Waiting
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 47da4524d17f: Waiting
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): a8ba81d08a13: Waiting
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): bd0287fb57f4: Waiting
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): e829239188f8: Waiting
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 93621bd20a35: Pushed
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 936f98862a75: Pushed
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 4652f1ecdb19: Pushed
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 47da4524d17f: Pushed
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0]: Still creating... [30s elapsed]
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 1986fa667ad1: Pushed
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): c9236a9b8b93: Pushed
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): bd0287fb57f4: Pushed
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): a8ba81d08a13: Pushed
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): e829239188f8: Pushed
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0]: Still creating... [40s elapsed]
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 710f14e8d0f7: Pushed
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] (local-exec): 0.0.1: digest: sha256:d45ab39221c207c145b57518a2bfa2919107c90665d8df1fb95b1f151af658f4 size: 2415
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0]: Creation complete after 40s [id=5956511922277536903]
module.oci-fk-custom-function.oci_functions_function.FoggyKitchenFn: Creating...
module.oci-fk-custom-function.oci_functions_function.FoggyKitchenFn: Creation complete after 1s [id=ocid1.fnfunc.oc1.eu-frankfurt-1.aaaaaaaa5easx22lxtmjpa53xfnuyby7opvrcnr6qgwxqz5cci6nwpuf6oqq]
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0]: Creating...
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0]: Provisioning with 'local-exec'...
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec): Executing: ["/bin/sh" "-c" "sleep 30"]
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0]: Still creating... [10s elapsed]
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0]: Still creating... [20s elapsed]
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0]: Still creating... [30s elapsed]
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0]: Provisioning with 'local-exec'...
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec): Executing: ["/bin/sh" "-c" "oci raw-request --http-method POST --target-uri https://5psktnoaeea.eu-frankfurt-1.functions.oci.oraclecloud.com/20181201/functions/ocid1.fnfunc.oc1.eu-frankfurt-1.aaaaaaaa5easx22lxtmjpa53xfnuyby7opvrcnr6qgwxqz5cci6nwpuf6oqq/actions/invoke --request-body '' "]
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0]: Still creating... [40s elapsed]
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0]: Still creating... [50s elapsed]
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec): {
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):   "data": {
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):     "message": "Here is custom message!"
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):   },
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):   "headers": {
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):     "Content-Length": "38",
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):     "Content-Type": "application/json",
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):     "Date": "Mon, 24 Jun 2024 15:13:27 GMT",
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):     "Fn-Call-Id": "01J15CXGGN1BT0JF8ZJ01CCY6M",
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):     "Fn-Fdk-Runtime": "python/3.8.5 final",
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):     "Fn-Fdk-Version": "fdk-python/0.1.73",
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):     "Opc-Request-Id": "8ACBE35814BB43ED9656CCBAEB9EB4C6/01J15CXGES00000000002MXDHY/01J15CXGES00000000002MXDHZ"
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):   },
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec):   "status": "200 OK"
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] (local-exec): }
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0]: Creation complete after 57s [id=1157409235786622962]

Apply complete! Resources: 16 added, 0 changed, 0 destroyed.

```
### Validate the deployment

1. From the hamburger menu in the top left corner, navigate to **Developer Services**, and then select **Applications**:

![](images/terraform-oci-fk-function-lesson2a.png)

2. Verify the existence of the `fkapp` application and the `fkcustom` function:

![](images/terraform-oci-fk-function-lesson2b.png)

3. Confirm that `fkcustom` has been invoked by checking the metrics section:

![](images/terraform-oci-fk-function-lesson2c.png)

4. Confirm that the custom message has been injected as part of the configuration by checking the environmental variable `FN_CUSTOM_MESSAGE`:

![](images/terraform-oci-fk-function-lesson2d.png)

5. Continue navigating to **Developer Services** and then to **Container Registry**:

![](images/terraform-oci-fk-function-lesson2e.png)

6. Confirm the existence of the Docker registry containing the `fkcustom` Docker image:

![](images/terraform-oci-fk-function-lesson2f.png)

### Destroy the changes 

Run the following command for destroying all resources:

```
martin_lin@codeeditor:lesson2_custom_function (eu-frankfurt-1)$ terraform destroy 

data.local_file.fncustom_requirements_txt: Reading...
data.local_file.fncustom_func_yaml: Reading...
data.local_file.fncustom_dockerfile: Reading...
data.local_file.fncustom_func_py: Reading...
data.local_file.fncustom_func_py: Read complete after 0s [id=871fae224158a4fdc178b10d9f52b88d58c484c1]
module.oci-fk-custom-function.local_file.func_py_content[0]: Refreshing state... [id=871fae224158a4fdc178b10d9f52b88d58c484c1]
data.local_file.fncustom_dockerfile: Read complete after 0s [id=aa3833301ffe31669490f8269952e79a0989b142]
data.local_file.fncustom_func_yaml: Read complete after 0s [id=8edf769e8713b427e6660888240ca0d0d39c7d88]
data.local_file.fncustom_requirements_txt: Read complete after 0s [id=91bd32a35ac20833294303bda57f32b4c1692a09]
module.oci-fk-custom-function.local_file.dockerfile_content[0]: Refreshing state... [id=aa3833301ffe31669490f8269952e79a0989b142]
module.oci-fk-custom-function.local_file.func_yaml_content[0]: Refreshing state... [id=8edf769e8713b427e6660888240ca0d0d39c7d88]
module.oci-fk-custom-function.local_file.requirements_txt_content[0]: Refreshing state... [id=91bd32a35ac20833294303bda57f32b4c1692a09]
module.oci-fk-custom-function.oci_artifacts_container_repository.FoggyKitchenOCIR: Refreshing state... [id=ocid1.containerrepo.oc1.eu-frankfurt-1.0.fr5tvfiq2xhq.aaaaaaaakfzc5egjsr4rkeoes7jfxkcxqayrsi6bga4b7m7neqq4sj72grtq]
module.oci-fk-custom-function.oci_logging_log_group.FoggyKitchenFnAppLogGroup[0]: Refreshing state... [id=ocid1.loggroup.oc1.eu-frankfurt-1.amaaaaaadngk4giazfnjuplvwskhlmdhhxp4qhezuucj4exk4py6v3aurzea]
module.oci-fk-custom-function.data.oci_objectstorage_namespace.os_namespace: Reading...
module.oci-fk-custom-function.oci_core_virtual_network.FoggyKitchenVCN[0]: Refreshing state... [id=ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaadngk4giar4nzswrlu6pfwxc4wexopnuumdgbxxywuoa2i5vub2mq]
module.oci-fk-custom-function.data.oci_identity_regions.oci_regions: Reading...
module.oci-fk-custom-function.data.oci_objectstorage_namespace.os_namespace: Read complete after 0s [id=ObjectStorageNamespaceDataSource-3596290162]
module.oci-fk-custom-function.data.oci_identity_regions.oci_regions: Read complete after 0s [id=IdentityRegionsDataSource-0]
module.oci-fk-custom-function.oci_core_dhcp_options.FoggyKitchenDhcpOptions1[0]: Refreshing state... [id=ocid1.dhcpoptions.oc1.eu-frankfurt-1.aaaaaaaamsuosgfu4bx3v3vj7szhwx733pxw4aigjkzkvwrn5k46zge6qaja]
module.oci-fk-custom-function.oci_core_internet_gateway.FoggyKitchenInternetGateway[0]: Refreshing state... [id=ocid1.internetgateway.oc1.eu-frankfurt-1.aaaaaaaa4mr2yswh4epoqq673w3hfguelohegbm2serryz5gahhtvl3xfpiq]
module.oci-fk-custom-function.oci_core_route_table.FoggyKitchenRouteTableViaIGW[0]: Refreshing state... [id=ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaar3gfjxy64ucgmy4qexnk3xrkhirh7624hzadtzhtgj6jjgbvpl4q]
module.oci-fk-custom-function.oci_core_subnet.FoggyKitchenPublicSubnet[0]: Refreshing state... [id=ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa75eacnhht7br3wyachr5nl7ejxpj3cbisxwaugfuownfrgjxmlbq]
module.oci-fk-custom-function.oci_functions_application.FoggyKitchenFnApp[0]: Refreshing state... [id=ocid1.fnapp.oc1.eu-frankfurt-1.aaaaaaaaa64z3pofrfegyu26k3rxfro7lq6axjhcisarweh3y5psktnoaeea]
module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0]: Refreshing state... [id=5956511922277536903]
module.oci-fk-custom-function.oci_logging_log.FoggyKitchenFnAppInvokeLog[0]: Refreshing state... [id=ocid1.log.oc1.eu-frankfurt-1.amaaaaaadngk4giagg6gi3twsgobaap55xkcx64lec57mol7zdvwux3lyola]
module.oci-fk-custom-function.oci_functions_function.FoggyKitchenFn: Refreshing state... [id=ocid1.fnfunc.oc1.eu-frankfurt-1.aaaaaaaa5easx22lxtmjpa53xfnuyby7opvrcnr6qgwxqz5cci6nwpuf6oqq]
module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0]: Refreshing state... [id=1157409235786622962]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # module.oci-fk-custom-function.local_file.dockerfile_content[0] will be destroyed
  - resource "local_file" "dockerfile_content" {
      - content              = <<-EOT
            FROM oraclelinux:8-slim as ol8
            
            RUN microdnf install -y wget \
                tar \
                gzip \
                which 
            
            FROM fnproject/python:3.8.5-dev as build-stage
            
            WORKDIR /function
            
            ADD requirements.txt /function/
            
            RUN pip3 install --target /python/  --no-cache --no-cache-dir -r requirements.txt && \                       
                rm -fr ~/.cache/pip /tmp* requirements.txt func.yaml Dockerfile .venv
            
            ADD . /function/
            
            RUN rm -fr /function/.pip_cache
            
            FROM fnproject/python:3.8.5
            
            WORKDIR /function
            
            COPY --from=build-stage /function /function
            
            COPY --from=build-stage /python /python
            
            ENV PYTHONPATH=/python
            
            ENTRYPOINT ["/python/bin/fdk", "/function/func.py", "handler"]
        EOT -> null
      - content_base64sha256 = "uN+n5grVDAa5G7i8LVEIiSDatLjZRlLeRgTFd8ric/4=" -> null
      - content_base64sha512 = "/bOBTMRwlmLpN2Qookg/3AF9MRXhsxAAqyHOcA6MTA945CLYYtiUTrduAlNJnk4M8uWGhz6abaNI+8not+y/1A==" -> null
      - content_md5          = "b4be4f8e7390d0ace2a7c04e6f8c69a6" -> null
      - content_sha1         = "aa3833301ffe31669490f8269952e79a0989b142" -> null
      - content_sha256       = "b8dfa7e60ad50c06b91bb8bc2d51088920dab4b8d94652de4604c577cae273fe" -> null
      - content_sha512       = "fdb3814cc4709662e9376428a2483fdc017d3115e1b31000ab21ce700e8c4c0f78e422d862d8944eb76e0253499e4e0cf2e586873e9a6da348fbc9e8b7ecbfd4" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0777" -> null
      - filename             = ".terraform/modules/oci-fk-custom-function/functions/fkFn/Dockerfile" -> null
      - id                   = "aa3833301ffe31669490f8269952e79a0989b142" -> null
    }

  # module.oci-fk-custom-function.local_file.func_py_content[0] will be destroyed
  - resource "local_file" "func_py_content" {
      - content              = <<-EOT
            import io
            import os
            import json
            import logging
            from fdk import response
            
            
            def handler(ctx, data: io.BytesIO=None):
            
                if os.getenv("FN_CUSTOM_MESSAGE") != None:
                    fn_custom_message = os.getenv("FN_CUSTOM_MESSAGE")
                else:
                    _='Missing configuration key FN_CUSTOM_MESSAGE'
                    logging.getLogger().error(_)
                    return None, _
            
                logging.getLogger().info(f'Starting function with message: {fn_custom_message}')
            
                return response.Response(
                    ctx, response_data=json.dumps(
                        {"message": fn_custom_message}),
                    headers={"Content-Type": "application/json"}
                )
        EOT -> null
      - content_base64sha256 = "zr05lEZhOEqByVc8BsyMBXuboDgpwBxGaSMN2G36XWs=" -> null
      - content_base64sha512 = "W0XggQj6RXJZ4DEMEf0Oi3RydYmitPH3aQSliMYgjt/jA1tw+VU/bomwwTA9E+4J3kRBD6Mr0/3sUAwp2aLXlQ==" -> null
      - content_md5          = "97773bfcb0f4bc2be1de0c260397f5d0" -> null
      - content_sha1         = "871fae224158a4fdc178b10d9f52b88d58c484c1" -> null
      - content_sha256       = "cebd39944661384a81c9573c06cc8c057b9ba03829c01c4669230dd86dfa5d6b" -> null
      - content_sha512       = "5b45e08108fa457259e0310c11fd0e8b74727589a2b4f1f76904a588c6208edfe3035b70f9553f6e89b0c1303d13ee09de44410fa32bd3fdec500c29d9a2d795" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0777" -> null
      - filename             = ".terraform/modules/oci-fk-custom-function/functions/fkFn/func.py" -> null
      - id                   = "871fae224158a4fdc178b10d9f52b88d58c484c1" -> null
    }

  # module.oci-fk-custom-function.local_file.func_yaml_content[0] will be destroyed
  - resource "local_file" "func_yaml_content" {
      - content              = <<-EOT
            schema_version: 20180708
            name: fncustom
            version: 0.0.1
            runtime: docker
            entrypoint: /python/bin/fdk /function/func.py handler
            memory: 256
        EOT -> null
      - content_base64sha256 = "l8ti1hMYmFBHTgF0JLfMokO6GGDNSfDVj3Lwiwhf20k=" -> null
      - content_base64sha512 = "DUC9nmvXU/95ctX7cYTxSFP4dZVo1rPKDC2f61VrkoeBfhip2BfDcWfEBC15jWR5Ny2dpu/sKo2rYktS3n9hEA==" -> null
      - content_md5          = "9ae93bdf5e20aa61bca324c4ff397b77" -> null
      - content_sha1         = "8edf769e8713b427e6660888240ca0d0d39c7d88" -> null
      - content_sha256       = "97cb62d613189850474e017424b7cca243ba1860cd49f0d58f72f08b085fdb49" -> null
      - content_sha512       = "0d40bd9e6bd753ff7972d5fb7184f14853f8759568d6b3ca0c2d9feb556b9287817e18a9d817c37167c4042d798d6479372d9da6efec2a8dab624b52de7f6110" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0777" -> null
      - filename             = ".terraform/modules/oci-fk-custom-function/functions/fkFn/func.yaml" -> null
      - id                   = "8edf769e8713b427e6660888240ca0d0d39c7d88" -> null
    }

  # module.oci-fk-custom-function.local_file.requirements_txt_content[0] will be destroyed
  - resource "local_file" "requirements_txt_content" {
      - content              = <<-EOT
            fdk
            oci
        EOT -> null
      - content_base64sha256 = "9vRbp5siszXS/f8RfuvR9Km3zcoZld1uApThY1gUD/s=" -> null
      - content_base64sha512 = "RGhttU6AljH3O0Qai5IHqdM9jPFQu6xim+bzTfA6eidOTCoBDgOhUVtG37GB/0kCF8DY8WbyuiRDjvRcKxxZYA==" -> null
      - content_md5          = "a3c417a33d200239f7dd5f055b510468" -> null
      - content_sha1         = "91bd32a35ac20833294303bda57f32b4c1692a09" -> null
      - content_sha256       = "f6f45ba79b22b335d2fdff117eebd1f4a9b7cdca1995dd6e0294e16358140ffb" -> null
      - content_sha512       = "44686db54e809631f73b441a8b9207a9d33d8cf150bbac629be6f34df03a7a274e4c2a010e03a1515b46dfb181ff490217c0d8f166f2ba24438ef45c2b1c5960" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0777" -> null
      - filename             = ".terraform/modules/oci-fk-custom-function/functions/fkFn/requirements.txt" -> null
      - id                   = "91bd32a35ac20833294303bda57f32b4c1692a09" -> null
    }

  # module.oci-fk-custom-function.null_resource.FoggyKitchenFnInvoke[0] will be destroyed
  - resource "null_resource" "FoggyKitchenFnInvoke" {
      - id = "1157409235786622962" -> null
    }

  # module.oci-fk-custom-function.null_resource.FoggyKitchenMyFnSetup[0] will be destroyed
  - resource "null_resource" "FoggyKitchenMyFnSetup" {
      - id = "5956511922277536903" -> null
    }

  # module.oci-fk-custom-function.oci_artifacts_container_repository.FoggyKitchenOCIR will be destroyed
  - resource "oci_artifacts_container_repository" "FoggyKitchenOCIR" {
      - billable_size_in_gbs = "0" -> null
      - compartment_id       = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null
      - created_by           = "ocid1.user.oc1..aaaaaaaahm27xm4lh7nnboyqkt7fxfo7yja5iqb6qpvqvq5eus22ogparkaa" -> null
      - defined_tags         = {} -> null
      - display_name         = "fkfn/fncustom" -> null
      - freeform_tags        = {} -> null
      - id                   = "ocid1.containerrepo.oc1.eu-frankfurt-1.0.fr5tvfiq2xhq.aaaaaaaakfzc5egjsr4rkeoes7jfxkcxqayrsi6bga4b7m7neqq4sj72grtq" -> null
      - image_count          = 1 -> null
      - is_immutable         = false -> null
      - is_public            = false -> null
      - layer_count          = 11 -> null
      - layers_size_in_bytes = "111196805" -> null
      - namespace            = "fr5tvfiq2xhq" -> null
      - state                = "AVAILABLE" -> null
      - system_tags          = {} -> null
      - time_created         = "2024-06-24 15:11:45.338 +0000 UTC" -> null
      - time_last_pushed     = "2024-06-24 15:12:29.731 +0000 UTC" -> null
    }

  # module.oci-fk-custom-function.oci_core_dhcp_options.FoggyKitchenDhcpOptions1[0] will be destroyed
  - resource "oci_core_dhcp_options" "FoggyKitchenDhcpOptions1" {
      - compartment_id   = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null
      - defined_tags     = {} -> null
      - display_name     = "FoggyKitchenDHCPOptions1" -> null
      - domain_name_type = "CUSTOM_DOMAIN" -> null
      - freeform_tags    = {} -> null
      - id               = "ocid1.dhcpoptions.oc1.eu-frankfurt-1.aaaaaaaamsuosgfu4bx3v3vj7szhwx733pxw4aigjkzkvwrn5k46zge6qaja" -> null
      - state            = "AVAILABLE" -> null
      - time_created     = "2024-06-24 15:11:46.003 +0000 UTC" -> null
      - vcn_id           = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaadngk4giar4nzswrlu6pfwxc4wexopnuumdgbxxywuoa2i5vub2mq" -> null

      - options {
          - custom_dns_servers  = [] -> null
          - search_domain_names = [
              - "foggykitchen.com",
            ] -> null
          - type                = "SearchDomain" -> null
        }
      - options {
          - custom_dns_servers  = [] -> null
          - search_domain_names = [] -> null
          - server_type         = "VcnLocalPlusInternet" -> null
          - type                = "DomainNameServer" -> null
        }
    }

  # module.oci-fk-custom-function.oci_core_internet_gateway.FoggyKitchenInternetGateway[0] will be destroyed
  - resource "oci_core_internet_gateway" "FoggyKitchenInternetGateway" {
      - compartment_id = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null
      - defined_tags   = {} -> null
      - display_name   = "FoggyKitchenInternetGateway" -> null
      - enabled        = true -> null
      - freeform_tags  = {} -> null
      - id             = "ocid1.internetgateway.oc1.eu-frankfurt-1.aaaaaaaa4mr2yswh4epoqq673w3hfguelohegbm2serryz5gahhtvl3xfpiq" -> null
      - state          = "AVAILABLE" -> null
      - time_created   = "2024-06-24 15:11:45.999 +0000 UTC" -> null
      - vcn_id         = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaadngk4giar4nzswrlu6pfwxc4wexopnuumdgbxxywuoa2i5vub2mq" -> null
    }

  # module.oci-fk-custom-function.oci_core_route_table.FoggyKitchenRouteTableViaIGW[0] will be destroyed
  - resource "oci_core_route_table" "FoggyKitchenRouteTableViaIGW" {
      - compartment_id = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null
      - defined_tags   = {} -> null
      - display_name   = "FoggyKitchenRouteTableViaIGW" -> null
      - freeform_tags  = {} -> null
      - id             = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaar3gfjxy64ucgmy4qexnk3xrkhirh7624hzadtzhtgj6jjgbvpl4q" -> null
      - state          = "AVAILABLE" -> null
      - time_created   = "2024-06-24 15:11:46.441 +0000 UTC" -> null
      - vcn_id         = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaadngk4giar4nzswrlu6pfwxc4wexopnuumdgbxxywuoa2i5vub2mq" -> null

      - route_rules {
          - destination       = "0.0.0.0/0" -> null
          - destination_type  = "CIDR_BLOCK" -> null
          - network_entity_id = "ocid1.internetgateway.oc1.eu-frankfurt-1.aaaaaaaa4mr2yswh4epoqq673w3hfguelohegbm2serryz5gahhtvl3xfpiq" -> null
        }
    }

  # module.oci-fk-custom-function.oci_core_subnet.FoggyKitchenPublicSubnet[0] will be destroyed
  - resource "oci_core_subnet" "FoggyKitchenPublicSubnet" {
      - cidr_block                 = "10.0.1.0/24" -> null
      - compartment_id             = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null
      - defined_tags               = {} -> null
      - dhcp_options_id            = "ocid1.dhcpoptions.oc1.eu-frankfurt-1.aaaaaaaamsuosgfu4bx3v3vj7szhwx733pxw4aigjkzkvwrn5k46zge6qaja" -> null
      - display_name               = "FoggyKitchenPublicSubnet" -> null
      - dns_label                  = "foggykitchenn1" -> null
      - freeform_tags              = {} -> null
      - id                         = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa75eacnhht7br3wyachr5nl7ejxpj3cbisxwaugfuownfrgjxmlbq" -> null
      - ipv6cidr_blocks            = [] -> null
      - prohibit_internet_ingress  = false -> null
      - prohibit_public_ip_on_vnic = false -> null
      - route_table_id             = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaar3gfjxy64ucgmy4qexnk3xrkhirh7624hzadtzhtgj6jjgbvpl4q" -> null
      - security_list_ids          = [
          - "ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaa37sccg7dozxbrkwzg5rkc723z43ft5wyhwxucr3wzdxfqqkyvl3q",
        ] -> null
      - state                      = "AVAILABLE" -> null
      - subnet_domain_name         = "foggykitchenn1.foggykitchenvcn.oraclevcn.com" -> null
      - time_created               = "2024-06-24 15:11:47.448 +0000 UTC" -> null
      - vcn_id                     = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaadngk4giar4nzswrlu6pfwxc4wexopnuumdgbxxywuoa2i5vub2mq" -> null
      - virtual_router_ip          = "10.0.1.1" -> null
      - virtual_router_mac         = "00:00:17:42:14:B6" -> null
    }

  # module.oci-fk-custom-function.oci_core_virtual_network.FoggyKitchenVCN[0] will be destroyed
  - resource "oci_core_virtual_network" "FoggyKitchenVCN" {
      - byoipv6cidr_blocks       = [] -> null
      - cidr_block               = "10.0.0.0/16" -> null
      - cidr_blocks              = [
          - "10.0.0.0/16",
        ] -> null
      - compartment_id           = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null
      - default_dhcp_options_id  = "ocid1.dhcpoptions.oc1.eu-frankfurt-1.aaaaaaaaszu5tj6icnxvhsckynw4naaqsmlczmstsgplsusjaur7qyfwmkjq" -> null
      - default_route_table_id   = "ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaa3mhcgp4rupqexl2myzzeck4phxp47tkb3iiwld4o6u75reoyqsiq" -> null
      - default_security_list_id = "ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaa37sccg7dozxbrkwzg5rkc723z43ft5wyhwxucr3wzdxfqqkyvl3q" -> null
      - defined_tags             = {} -> null
      - display_name             = "FoggyKitchenVCN" -> null
      - dns_label                = "foggykitchenvcn" -> null
      - freeform_tags            = {} -> null
      - id                       = "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaadngk4giar4nzswrlu6pfwxc4wexopnuumdgbxxywuoa2i5vub2mq" -> null
      - ipv6cidr_blocks          = [] -> null
      - ipv6private_cidr_blocks  = [] -> null
      - is_ipv6enabled           = false -> null
      - state                    = "AVAILABLE" -> null
      - time_created             = "2024-06-24 15:11:45.341 +0000 UTC" -> null
      - vcn_domain_name          = "foggykitchenvcn.oraclevcn.com" -> null
    }

  # module.oci-fk-custom-function.oci_functions_application.FoggyKitchenFnApp[0] will be destroyed
  - resource "oci_functions_application" "FoggyKitchenFnApp" {
      - compartment_id             = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null
      - config                     = {} -> null
      - defined_tags               = {} -> null
      - display_name               = "fkapp" -> null
      - freeform_tags              = {} -> null
      - id                         = "ocid1.fnapp.oc1.eu-frankfurt-1.aaaaaaaaa64z3pofrfegyu26k3rxfro7lq6axjhcisarweh3y5psktnoaeea" -> null
      - network_security_group_ids = [] -> null
      - shape                      = "GENERIC_ARM" -> null
      - state                      = "ACTIVE" -> null
      - subnet_ids                 = [
          - "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa75eacnhht7br3wyachr5nl7ejxpj3cbisxwaugfuownfrgjxmlbq",
        ] -> null
      - time_created               = "2024-06-24 15:11:49.246 +0000 UTC" -> null
      - time_updated               = "2024-06-24 15:11:49.246 +0000 UTC" -> null

      - trace_config {
          - is_enabled = false -> null
        }
    }

  # module.oci-fk-custom-function.oci_functions_function.FoggyKitchenFn will be destroyed
  - resource "oci_functions_function" "FoggyKitchenFn" {
      - application_id     = "ocid1.fnapp.oc1.eu-frankfurt-1.aaaaaaaaa64z3pofrfegyu26k3rxfro7lq6axjhcisarweh3y5psktnoaeea" -> null
      - compartment_id     = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null
      - config             = {
          - "FN_CUSTOM_MESSAGE" = "Here is custom message!"
        } -> null
      - defined_tags       = {} -> null
      - display_name       = "fncustom" -> null
      - freeform_tags      = {} -> null
      - id                 = "ocid1.fnfunc.oc1.eu-frankfurt-1.aaaaaaaa5easx22lxtmjpa53xfnuyby7opvrcnr6qgwxqz5cci6nwpuf6oqq" -> null
      - image              = "fra.ocir.io/fr5tvfiq2xhq/fkfn/fncustom:0.0.1" -> null
      - image_digest       = "sha256:d45ab39221c207c145b57518a2bfa2919107c90665d8df1fb95b1f151af658f4" -> null
      - invoke_endpoint    = "https://5psktnoaeea.eu-frankfurt-1.functions.oci.oraclecloud.com" -> null
      - memory_in_mbs      = "256" -> null
      - shape              = "GENERIC_ARM" -> null
      - state              = "ACTIVE" -> null
      - time_created       = "2024-06-24 15:12:30.265 +0000 UTC" -> null
      - time_updated       = "2024-06-24 15:12:30.265 +0000 UTC" -> null
      - timeout_in_seconds = 30 -> null

      - trace_config {
          - is_enabled = false -> null
        }
    }

  # module.oci-fk-custom-function.oci_logging_log.FoggyKitchenFnAppInvokeLog[0] will be destroyed
  - resource "oci_logging_log" "FoggyKitchenFnAppInvokeLog" {
      - compartment_id     = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null
      - defined_tags       = {} -> null
      - display_name       = "FoggyKitchenFnAppInvokeLog" -> null
      - freeform_tags      = {} -> null
      - id                 = "ocid1.log.oc1.eu-frankfurt-1.amaaaaaadngk4giagg6gi3twsgobaap55xkcx64lec57mol7zdvwux3lyola" -> null
      - is_enabled         = true -> null
      - log_group_id       = "ocid1.loggroup.oc1.eu-frankfurt-1.amaaaaaadngk4giazfnjuplvwskhlmdhhxp4qhezuucj4exk4py6v3aurzea" -> null
      - log_type           = "SERVICE" -> null
      - retention_duration = 30 -> null
      - state              = "ACTIVE" -> null
      - tenancy_id         = "ocid1.tenancy.oc1..aaaaaaaasbktycknc4n4ja673cmnldkrj2s3gdbz7d2heqzzxn7pe64ksbia" -> null
      - time_created       = "2024-06-24 15:11:49.445 +0000 UTC" -> null
      - time_last_modified = "2024-06-24 15:11:49.445 +0000 UTC" -> null

      - configuration {
          - compartment_id = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null

          - source {
              - category    = "invoke" -> null
              - parameters  = {} -> null
              - resource    = "ocid1.fnapp.oc1.eu-frankfurt-1.aaaaaaaaa64z3pofrfegyu26k3rxfro7lq6axjhcisarweh3y5psktnoaeea" -> null
              - service     = "functions" -> null
              - source_type = "OCISERVICE" -> null
            }
        }
    }

  # module.oci-fk-custom-function.oci_logging_log_group.FoggyKitchenFnAppLogGroup[0] will be destroyed
  - resource "oci_logging_log_group" "FoggyKitchenFnAppLogGroup" {
      - compartment_id     = "ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32v5rlniicwmpxsytywiucgbcp5ext6e4ahjfuloewa" -> null
      - defined_tags       = {} -> null
      - description        = "Foggy Kitchen Fn App Log Group" -> null
      - display_name       = "FoggyKitchenFnAppLogGroup" -> null
      - freeform_tags      = {} -> null
      - id                 = "ocid1.loggroup.oc1.eu-frankfurt-1.amaaaaaadngk4giazfnjuplvwskhlmdhhxp4qhezuucj4exk4py6v3aurzea" -> null
      - state              = "ACTIVE" -> null
      - time_created       = "2024-06-24 15:11:45.348 +0000 UTC" -> null
      - time_last_modified = "2024-06-24 15:11:45.348 +0000 UTC" -> null
    }

Plan: 0 to add, 0 to change, 16 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.
    
  Enter a value: yes

(...)

module.oci-fk-custom-function.oci_functions_application.FoggyKitchenFnApp[0]: Still destroying... [id=ocid1.fnapp.oc1.eu-frankfurt-1.aaaaaaaa...26k3rxfro7lq6axjhcisarweh3y5psktnoaeea, 4m30s elapsed]
module.oci-fk-custom-function.oci_functions_application.FoggyKitchenFnApp[0]: Still destroying... [id=ocid1.fnapp.oc1.eu-frankfurt-1.aaaaaaaa...26k3rxfro7lq6axjhcisarweh3y5psktnoaeea, 4m40s elapsed]
module.oci-fk-custom-function.oci_functions_application.FoggyKitchenFnApp[0]: Still destroying... [id=ocid1.fnapp.oc1.eu-frankfurt-1.aaaaaaaa...26k3rxfro7lq6axjhcisarweh3y5psktnoaeea, 4m50s elapsed]
module.oci-fk-custom-function.oci_functions_application.FoggyKitchenFnApp[0]: Still destroying... [id=ocid1.fnapp.oc1.eu-frankfurt-1.aaaaaaaa...26k3rxfro7lq6axjhcisarweh3y5psktnoaeea, 5m0s elapsed]
module.oci-fk-custom-function.oci_functions_application.FoggyKitchenFnApp[0]: Destruction complete after 5m0s
module.oci-fk-custom-function.oci_core_subnet.FoggyKitchenPublicSubnet[0]: Destroying... [id=ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa75eacnhht7br3wyachr5nl7ejxpj3cbisxwaugfuownfrgjxmlbq]
module.oci-fk-custom-function.oci_core_subnet.FoggyKitchenPublicSubnet[0]: Destruction complete after 1s
module.oci-fk-custom-function.oci_core_dhcp_options.FoggyKitchenDhcpOptions1[0]: Destroying... [id=ocid1.dhcpoptions.oc1.eu-frankfurt-1.aaaaaaaamsuosgfu4bx3v3vj7szhwx733pxw4aigjkzkvwrn5k46zge6qaja]
module.oci-fk-custom-function.oci_core_route_table.FoggyKitchenRouteTableViaIGW[0]: Destroying... [id=ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaar3gfjxy64ucgmy4qexnk3xrkhirh7624hzadtzhtgj6jjgbvpl4q]
module.oci-fk-custom-function.oci_core_dhcp_options.FoggyKitchenDhcpOptions1[0]: Destruction complete after 0s
module.oci-fk-custom-function.oci_core_route_table.FoggyKitchenRouteTableViaIGW[0]: Destruction complete after 0s
module.oci-fk-custom-function.oci_core_internet_gateway.FoggyKitchenInternetGateway[0]: Destroying... [id=ocid1.internetgateway.oc1.eu-frankfurt-1.aaaaaaaa4mr2yswh4epoqq673w3hfguelohegbm2serryz5gahhtvl3xfpiq]
module.oci-fk-custom-function.oci_core_internet_gateway.FoggyKitchenInternetGateway[0]: Destruction complete after 1s
module.oci-fk-custom-function.oci_core_virtual_network.FoggyKitchenVCN[0]: Destroying... [id=ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaadngk4giar4nzswrlu6pfwxc4wexopnuumdgbxxywuoa2i5vub2mq]
module.oci-fk-custom-function.oci_core_virtual_network.FoggyKitchenVCN[0]: Destruction complete after 0s

Destroy complete! Resources: 16 destroyed.

```
