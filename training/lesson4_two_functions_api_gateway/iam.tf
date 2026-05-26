data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

module "fk_policy_apigateway_functions" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-policy.git?ref=v0.1.0"

  providers = {
    oci = oci.homeregion
  }

  tenancy_ocid = var.tenancy_ocid

  policies = [
    {
      name        = "fk_fn_lesson4_apigateway_policy"
      description = "Allow OCI API Gateway to invoke Functions in the lesson4 compartment"
      statements = [
        "ALLOW any-user to use functions-family in compartment id ${var.compartment_ocid} where ALL { request.principal.type = 'ApiGateway', request.resource.compartment.id = '${var.compartment_ocid}' }"
      ]
    }
  ]
}
