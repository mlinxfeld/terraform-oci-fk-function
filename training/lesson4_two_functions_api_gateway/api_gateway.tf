module "fk_api_gateway" {
  source = "github.com/foggykitchen/terraform-oci-fk-api-gateway"

  name             = "fk-fn-lesson4-api-gateway"
  compartment_ocid = var.compartment_ocid
  subnet_id        = module.fk_vcn.subnet_ids["apigw_public"]
  path_prefix      = "/v1"

  routes = [
    {
      name    = "fncustom1"
      path    = "/fncustom1"
      methods = ["POST"]
      backend = {
        type        = "ORACLE_FUNCTIONS_BACKEND"
        function_id = module.oci-fk-custom-function-1.oci_app_fn.fn_ocid
      }
    },
    {
      name    = "fncustom2"
      path    = "/fncustom2"
      methods = ["POST"]
      backend = {
        type        = "ORACLE_FUNCTIONS_BACKEND"
        function_id = module.oci-fk-custom-function-2.oci_app_fn.fn_ocid
      }
    }
  ]

  depends_on = [module.fk_policy_apigateway_functions]
}
