
output "api_gateway_endpoints" {
  value = {
    fninitiator_endpoint = module.fk_api_gateway.route_endpoints["fninitiator"]
  }
}

output "fn_jwt_token" {
  value = var.fn_jwt_token
}

output "objectstorage_bucket" {
  value = module.fk_objectstorage.buckets["iot_data"]
}
