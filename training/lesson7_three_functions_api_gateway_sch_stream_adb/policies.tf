module "fk_policy_apigateway_functions" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-policy.git?ref=v0.1.0"

  providers = {
    oci = oci.homeregion
  }

  tenancy_ocid = var.tenancy_ocid

  policies = [
    {
      name        = "fk_fn_lesson7_apigateway_policy"
      description = "Allow OCI API Gateway to invoke Functions in the lesson7 compartment"
      statements = [
        "ALLOW any-user to use functions-family in compartment id ${var.compartment_ocid} where ALL { request.principal.type = 'ApiGateway', request.resource.compartment.id = '${var.compartment_ocid}' }"
      ]
    }
  ]
}

module "fk_policy_function_dataflow" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-policy.git?ref=v0.1.0"

  providers = {
    oci = oci.homeregion
  }

  tenancy_ocid = var.tenancy_ocid

  dynamic_group = {
    name          = "fk_fn_lesson7_dg"
    description   = "Dynamic group for lesson7 Functions that publish to Streaming and use ADB"
    matching_rule = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}'}"
  }

  policies = [
    {
      name        = "fk_fn_lesson7_stream_policy"
      description = "Allow lesson7 Functions to push records to OCI Streaming"
      statements = [
        "Allow dynamic-group fk_fn_lesson7_dg to manage all-resources in compartment id ${var.compartment_ocid}",
        "Allow dynamic-group fk_fn_lesson7_dg to use stream-push in compartment id ${var.compartment_ocid}"
      ]
    },
    {
      name        = "fk_fn_lesson7_adb_policy"
      description = "Allow lesson7 Functions to use Autonomous Database resources"
      statements = [
        "Allow dynamic-group fk_fn_lesson7_dg to use database-family in compartment id ${var.compartment_ocid}",
        "Allow dynamic-group fk_fn_lesson7_dg to manage autonomous-database in compartment id ${var.compartment_ocid}"
      ]
    }
  ]
}

module "fk_policy_sch_connector" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-policy.git?ref=v0.1.0"

  providers = {
    oci = oci.homeregion
  }

  tenancy_ocid = var.tenancy_ocid

  policies = [
    {
      name        = "fk_fn_lesson7_sch_policy"
      description = "Allow Service Connector Hub to consume from Streaming and invoke the collector function"
      statements = [
        "Allow any-user to {STREAM_READ, STREAM_CONSUME} in compartment id ${var.compartment_ocid} where all {request.principal.type='serviceconnector', target.stream.id='${module.fk_streaming.stream_ids["iot_data"]}', request.principal.compartment.id='${var.compartment_ocid}'}",
        "Allow any-user to use fn-function in compartment id ${var.compartment_ocid} where all {request.principal.type='serviceconnector', request.principal.compartment.id='${var.compartment_ocid}'}",
        "Allow any-user to use fn-invocation in compartment id ${var.compartment_ocid} where all {request.principal.type='serviceconnector', request.principal.compartment.id='${var.compartment_ocid}'}"
      ]
    }
  ]
}
