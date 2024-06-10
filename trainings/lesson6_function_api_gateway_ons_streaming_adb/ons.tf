resource "oci_ons_notification_topic" "FoggyKitchenTopic" {
    compartment_id = var.compartment_ocid
    name           = "FoggyKitchenTopic"
    description    = "This topic triggers the fncollector function"
}

resource "oci_ons_subscription" "FoggyKitchenSubscription" {
    compartment_id = var.compartment_ocid
    endpoint       = module.oci-fk-collector-function.oci_app_fn.fn_ocid 
    protocol       = "ORACLE_FUNCTIONS"
    topic_id       = oci_ons_notification_topic.FoggyKitchenTopic.id
}
