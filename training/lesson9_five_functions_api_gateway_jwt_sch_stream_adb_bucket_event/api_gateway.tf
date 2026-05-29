module "fk_api_gateway" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-api-gateway.git?ref=v0.1.1"

  name             = "fk-fn-lesson9-api-gateway"
  compartment_ocid = var.compartment_ocid
  subnet_id        = module.fk_vcn.subnet_ids["apigw_public"]
  path_prefix      = "/v1"

  custom_authentication = {
    function_id  = module.oci-fk-jwt-auth-function.oci_app_fn.fn_ocid
    token_header = "token"
  }

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
