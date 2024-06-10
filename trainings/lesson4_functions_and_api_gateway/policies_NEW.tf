resource "oci_identity_policy" "FoggyKitchenAnyUserUseFnPolicy" {
  provider = oci.homeregion  
  name = "FoggyKitchenAnyUserUseFnPolicy"
  description = "FoggyKitchenAnyUserUseFnPolicy"
  compartment_id = var.compartment_ocid
  statements = ["ALLOW any-user to use functions-family in compartment id ${var.compartment_ocid} where ALL { request.principal.type= 'ApiGateway' , request.resource.compartment.id = '${var.compartment_ocid}'}"]
}
