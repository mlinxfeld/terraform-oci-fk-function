output "api_gateway_endpoints" {
  description = "Resolved API Gateway endpoints for both custom functions."
  value = {
    fn_custom1_endpoint = module.fk_api_gateway.route_endpoints["fncustom1"]
    fn_custom2_endpoint = module.fk_api_gateway.route_endpoints["fncustom2"]
  }
}
