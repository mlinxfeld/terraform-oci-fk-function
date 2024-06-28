resource "oci_events_rule" "FoggyKitchenOSSEvent" {
    actions {
        actions {
            action_type = "FAAS"
            is_enabled  = true
            description = "Invoke fnbulkload when JSON object uploaded to bucket"
            function_id = module.oci-fk-bulk-load-function.oci_app_fn.fn_ocid
        }
    }
    compartment_id = var.compartment_ocid
    condition = "{ \"eventType\": \"com.oraclecloud.objectstorage.createobject\", \"data\": {\"additionalDetails\": {\"bucketId\": \"${oci_objectstorage_bucket.FoggyKitchenBucket.bucket_id}\" } } }"
    display_name = "FoggyKitchenOSSEvent"
    is_enabled = true
}
