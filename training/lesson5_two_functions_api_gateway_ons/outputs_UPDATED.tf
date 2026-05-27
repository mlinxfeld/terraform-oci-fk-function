output "api_gateway_endpoints" {
  description = "Resolved API Gateway endpoint for the public initiator function."
  value = {
    fninitiator_endpoint = module.fk_api_gateway.route_endpoints["fninitiator"]
  }
}
