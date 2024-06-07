output "oci_app_fn" {
  value = {
    fn_app_ocid    = var.use_my_fn_app ? var.my_fn_app_ocid : oci_functions_application.FoggyKitchenFnApp[0].id
    fn_ocid        = oci_functions_function.FoggyKitchenFn.id
    fn_subnet_ocid = var.use_my_fn_network ? var.my_fn_subnet_ocid : oci_core_subnet.FoggyKitchenPublicSubnet[0].id
  }
}
