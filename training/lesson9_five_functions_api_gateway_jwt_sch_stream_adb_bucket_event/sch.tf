resource "oci_sch_service_connector" "FoggyKitchenServiceConnector" {
    compartment_id = var.compartment_ocid
    display_name = "FoggyKitchenServiceConnector"
    description  = "FoggyKitchen Service Connector Hub"
    source {
      kind = "streaming"
      stream_id = oci_streaming_stream.FoggyKitchenStream.id
      cursor {
        kind = "TRIM_HORIZON"
      }
    }
    target {
      kind = "functions"
      function_id = module.oci-fk-collector-function.oci_app_fn.fn_ocid
    }
}
