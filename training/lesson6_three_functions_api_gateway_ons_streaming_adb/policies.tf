resource "oci_identity_policy" "FoggyKitchenAPIGatewayPolicy" {
  provider = oci.homeregion  
  name = "FoggyKitchenAPIGatewayPolicy"
  description = "FoggyKitchenAPIGatewayPolicy"
  compartment_id = var.compartment_ocid
  statements = ["ALLOW any-user to use functions-family in compartment id ${var.compartment_ocid} where ALL { request.principal.type= 'ApiGateway' , request.resource.compartment.id = '${var.compartment_ocid}'}"]
}

resource "oci_identity_dynamic_group" "FoggyKitchenFunctionDG" {
  provider       = oci.homeregion  
  compartment_id = var.tenancy_ocid
  name           = "FoggyKitchenFunctionDG"
  description    = "FoggyKitchen Function Dynamic Group"
  matching_rule  = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}'}"
}

resource "oci_identity_policy" "FoggyKitchenFnONSPolicy" {
  provider = oci.homeregion  
  name = "FoggyKitchenFnONSPolicy"
  description = "FoggyKitchenFnONSPolicy"
  compartment_id = var.tenancy_ocid

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenFunctionDG.name} to manage ons-topics in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenFunctionDG.name} to use ons-subscriptions in tenancy"
  ]
}  
resource "oci_identity_policy" "FoggyKitchenFnStreamPolicy" {
  provider = oci.homeregion  
  name = "FoggyKitchenFnStreamPolicy"
  description = "FoggyKitchenFnStreamPolicy"
  compartment_id = var.tenancy_ocid

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenFunctionDG.name} to manage all-resources in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenFunctionDG.name} to use stream-push in compartment id ${var.compartment_ocid}"
  ]
}

resource "oci_identity_policy" "FoggyKitchenFnADBPolicy" {
  provider       = oci.homeregion  
  depends_on     = [oci_identity_dynamic_group.FoggyKitchenFunctionDG]
  name           = "FoggyKitchenFnADBPolicy"
  description    = "FoggyKitchenFnADBPolicy"
  compartment_id = var.tenancy_ocid

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenFunctionDG.name} to use database-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.FoggyKitchenFunctionDG.name} to manage autonomous-database in compartment id ${var.compartment_ocid}"
  ]
}