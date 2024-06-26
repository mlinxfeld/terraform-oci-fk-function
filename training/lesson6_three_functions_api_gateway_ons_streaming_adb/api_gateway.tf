resource "oci_apigateway_gateway" "FoggyKitchenAPIGateway" {
  compartment_id = var.compartment_ocid
  endpoint_type  = "PUBLIC"
  subnet_id      = oci_core_subnet.FoggyKitchenPublicSubnet.id
  display_name   = "FoggyKitchenAPIGateway"
}


resource "oci_apigateway_deployment" "FoggyKitchenAPIGatewayDeployment" {
  compartment_id = var.compartment_ocid
  gateway_id     = oci_apigateway_gateway.FoggyKitchenAPIGateway.id
  path_prefix    = "/v1"
  display_name   = "FoggyKitchenAPIGatewayDeployment"

  specification {
    routes {
      backend {
          type        = "ORACLE_FUNCTIONS_BACKEND"
          function_id = module.oci-fk-initiator-function.oci_app_fn.fn_ocid
      }
      methods = ["POST"]
      path    = "/fninitiator"

    }
  }
}