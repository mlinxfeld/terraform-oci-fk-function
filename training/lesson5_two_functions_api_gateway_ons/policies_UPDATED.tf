module "fk_policy_apigateway_functions" {
  source = "../../../terraform-oci-fk-policy"

  providers = {
    oci = oci.homeregion
  }

  tenancy_ocid = var.tenancy_ocid

  policies = [
    {
      name        = "fk_fn_lesson5_apigateway_policy"
      description = "Allow OCI API Gateway to invoke Functions in the lesson5 compartment"
      statements = [
        "ALLOW any-user to use functions-family in compartment id ${var.compartment_ocid} where ALL { request.principal.type = 'ApiGateway', request.resource.compartment.id = '${var.compartment_ocid}' }"
      ]
    }
  ]
}

module "fk_policy_function_ons" {
  source = "../../../terraform-oci-fk-policy"

  providers = {
    oci = oci.homeregion
  }

  tenancy_ocid = var.tenancy_ocid

  dynamic_group = {
    name          = "fk_fn_lesson5_dg"
    description   = "Dynamic group for lesson5 Functions that publish to OCI Notifications"
    matching_rule = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}'}"
  }

  policies = [
    {
      name        = "fk_fn_lesson5_ons_policy"
      description = "Allow lesson5 Functions to publish to OCI Notifications"
      statements = [
        "Allow dynamic-group fk_fn_lesson5_dg to manage ons-topics in tenancy",
        "Allow dynamic-group fk_fn_lesson5_dg to use ons-subscriptions in tenancy"
      ]
    }
  ]
}
