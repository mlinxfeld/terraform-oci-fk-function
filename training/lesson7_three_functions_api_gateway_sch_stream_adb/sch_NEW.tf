module "fk_sch" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-sch.git?ref=main"

  name             = "fk-fn-lesson7-sch"
  compartment_ocid = var.compartment_ocid
  description      = "Service Connector Hub connector for lesson7 Streaming to Functions delivery"

  streaming_source = {
    stream_id   = module.fk_streaming.stream_ids["iot_data"]
    cursor_kind = "TRIM_HORIZON"
  }

  functions_target = {
    function_id = module.oci-fk-collector-function.oci_app_fn.fn_ocid
  }

  depends_on = [module.fk_policy_sch_connector]
}
