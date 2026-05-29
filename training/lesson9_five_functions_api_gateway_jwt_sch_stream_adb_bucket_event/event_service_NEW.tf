module "fk_event_bucket_bulkload" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-event.git?ref=v0.1.0"

  name             = "fk-fn-lesson9-bucket-event"
  compartment_ocid = var.compartment_ocid
  rule_name        = "FoggyKitchenOSSEvent"
  description      = "Invoke fnbulkload when a JSON object is uploaded to the lesson9 bucket"
  condition = jsonencode({
    eventType = "com.oraclecloud.objectstorage.createobject"
    data = {
      additionalDetails = {
        bucketId = module.fk_objectstorage.bucket_ids["iot_data"]
      }
    }
  })

  actions = [
    {
      action_type = "FAAS"
      is_enabled  = true
      description = "Invoke fnbulkload when JSON object uploaded to bucket"
      function_id = module.oci-fk-bulk-load-function.oci_app_fn.fn_ocid
    }
  ]
}
