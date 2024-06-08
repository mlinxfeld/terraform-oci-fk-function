output "api_gateway_endpoints" {
  value = {
    fninitiator_endpoint = join("/",[oci_apigateway_deployment.FoggyKitchenAPIGatewayDeployment.endpoint,"fninitiator"])
  }
}  