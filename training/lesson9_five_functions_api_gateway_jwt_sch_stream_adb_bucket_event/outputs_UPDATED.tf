
output "api_gateway_endpoints" {
  value = {
    fninitiator_endpoint = join("/",[oci_apigateway_deployment.FoggyKitchenAPIGatewayDeployment.endpoint,"fninitiator"])
  }
}  

output "fn_jwt_token" {
  value = var.fn_jwt_token
}