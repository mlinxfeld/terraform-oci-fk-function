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

resource "oci_identity_policy" "FoggyKitchenFnSCHPolicy" {
  provider = oci.homeregion  
  name = "FoggyKitchenFnSCHPolicy"
  description = "FoggyKitchenFnSCHPolicy"
  compartment_id = var.tenancy_ocid

  statements = [
   "Allow any-user to {STREAM_READ, STREAM_CONSUME} in compartment id ${var.compartment_ocid} where all {request.principal.type='serviceconnector', target.stream.id='${oci_streaming_stream.FoggyKitchenStream.id}', request.principal.compartment.id='${var.compartment_ocid}'}",
   "Allow any-user to use fn-function in compartment id ${var.compartment_ocid} where all {request.principal.type='serviceconnector', request.principal.compartment.id='${var.compartment_ocid}'}",
   "Allow any-user to use fn-invocation in compartment id ${var.compartment_ocid} where all {request.principal.type='serviceconnector', request.principal.compartment.id='${var.compartment_ocid}'}"
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