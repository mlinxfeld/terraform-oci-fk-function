output "api_gateway_endpoints" {
  value = {
    fn_custom1_endpoint = join("/",[oci_apigateway_deployment.FoggyKitchenAPIGatewayDeployment.endpoint,"fncustom1"])
    fn_custom2_endpoint = join("/",[oci_apigateway_deployment.FoggyKitchenAPIGatewayDeployment.endpoint,"fncustom2"])
  }
}  