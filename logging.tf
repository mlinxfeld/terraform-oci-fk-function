
resource "oci_logging_log_group" "FoggyKitchenFnAppLogGroup" {
    count          = var.use_oci_logging ? 1 : 0     
    compartment_id = var.compartment_ocid
    display_name   = var.oci_logging_group_name
    description    = var.oci_logging_group_description
}

resource "oci_logging_log" "FoggyKitchenFnAppInvokeLog" {
    count        = var.use_oci_logging ? 1 : 0  
    display_name = var.oci_logging_log_name
    log_group_id = oci_logging_log_group.FoggyKitchenFnAppLogGroup[0].id
    log_type = "SERVICE"


    configuration {
        source {
            category = "invoke"
            resource = var.use_my_fn_app ? var.my_fn_app_ocid : oci_functions_application.FoggyKitchenFnApp[0].id
            service = "functions"
            source_type = "OCISERVICE"
        }

        compartment_id = var.compartment_ocid
    }
    is_enabled = true
}