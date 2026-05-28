module "fk_ons" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-ons.git?ref=v0.1.0"

  compartment_ocid  = var.compartment_ocid
  name              = "fk-fn-lesson6-topic"
  topic_name        = "fk-fn-lesson6-topic"
  topic_description = "This topic triggers the fncollector function"

  subscriptions = {
    fncollector = {
      protocol = "ORACLE_FUNCTIONS"
      endpoint = module.oci-fk-collector-function.oci_app_fn.fn_ocid
    }
  }
}
