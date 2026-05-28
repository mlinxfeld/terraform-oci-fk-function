module "oci-fk-adb" {
  source                                = "git::https://github.com/foggykitchen/terraform-oci-fk-adb.git?ref=v1.3"
  adb_database_db_name                  = var.adb_database_db_name
  adb_database_display_name             = var.adb_database_db_name
  adb_password                          = var.adb_admin_password
  adb_database_db_workload              = "OLTP"
  adb_free_tier                         = true
  adb_compute_count                     = 2
  adb_database_cpu_core_count           = 0
  adb_database_data_storage_size_in_tbs = 1
  compartment_ocid                      = var.compartment_ocid
  use_existing_vcn                      = false
  adb_private_endpoint                  = false
}
