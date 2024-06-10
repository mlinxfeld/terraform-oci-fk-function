resource "oci_identity_policy" "FoggyKitchenAnyUserUseFnPolicy" {
  provider = oci.homeregion  
  name = "FoggyKitchenAnyUserUseFnPolicy"
  description = "FoggyKitchenAnyUserUseFnPolicy"
  compartment_id = var.compartment_ocid
  statements = ["ALLOW any-user to use functions-family in compartment id ${var.compartment_ocid} where ALL { request.principal.type= 'ApiGateway' , request.resource.compartment.id = '${var.compartment_ocid}'}"]
}

# Added Dynamic Group and Policy for ONS

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
    "Allow dynamic-group FoggyKitchenFunctionDG to manage ons-topics in tenancy",
    "Allow dynamic-group FoggyKitchenFunctionDG to use ons-subscriptions in tenancy"
  ]
}  