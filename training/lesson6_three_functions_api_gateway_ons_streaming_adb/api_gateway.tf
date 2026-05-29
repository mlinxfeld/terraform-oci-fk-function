module "fk_api_gateway" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-api-gateway.git?ref=main"

  name             = "fk-fn-lesson6-api-gateway"
  compartment_ocid = var.compartment_ocid
  subnet_id        = module.fk_vcn.subnet_ids["apigw_public"]
  path_prefix      = "/v1"

  routes = [
    {
      name    = "fninitiator"
      path    = "/fninitiator"
      methods = ["POST"]
      backend = {
        type        = "ORACLE_FUNCTIONS_BACKEND"
        function_id = module.oci-fk-initiator-function.oci_app_fn.fn_ocid
      }
    }
  ]

  depends_on = [module.fk_policy_apigateway_functions]
}
