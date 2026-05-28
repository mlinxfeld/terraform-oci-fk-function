module "fk_policy_apigateway_functions" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-policy.git?ref=v0.1.0"

  providers = {
    oci = oci.homeregion
  }

  tenancy_ocid = var.tenancy_ocid

  policies = [
    {
      name        = "fk_fn_lesson6_apigateway_policy"
      description = "Allow OCI API Gateway to invoke Functions in the lesson6 compartment"
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
    name          = "fk_fn_lesson6_dg"
    description   = "Dynamic group for lesson6 Functions that publish to ONS, Streaming, and ADB"
    matching_rule = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}'}"
  }

  policies = [
    {
      name        = "fk_fn_lesson6_ons_policy"
      description = "Allow lesson6 Functions to publish to OCI Notifications"
      statements = [
        "Allow dynamic-group fk_fn_lesson6_dg to manage ons-topics in tenancy",
        "Allow dynamic-group fk_fn_lesson6_dg to use ons-subscriptions in tenancy"
      ]
    },
    {
      name        = "fk_fn_lesson6_stream_policy"
      description = "Allow lesson6 Functions to use OCI Streaming"
      statements = [
        "Allow dynamic-group fk_fn_lesson6_dg to manage all-resources in compartment id ${var.compartment_ocid}",
        "Allow dynamic-group fk_fn_lesson6_dg to use stream-push in compartment id ${var.compartment_ocid}"
      ]
    },
    {
      name        = "fk_fn_lesson6_adb_policy"
      description = "Allow lesson6 Functions to use Autonomous Database resources"
      statements = [
        "Allow dynamic-group fk_fn_lesson6_dg to use database-family in compartment id ${var.compartment_ocid}",
        "Allow dynamic-group fk_fn_lesson6_dg to manage autonomous-database in compartment id ${var.compartment_ocid}"
      ]
    }
  ]
}
