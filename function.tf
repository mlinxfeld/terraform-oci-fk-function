resource "oci_functions_application" "FoggyKitchenFnApp" {
    count          = var.use_my_fn_app ? 0 : 1 
    compartment_id = var.compartment_ocid
    display_name   = var.fk_app_name
    subnet_ids     = var.use_my_fn_network ? [var.my_fn_subnet_ocid] : [oci_core_subnet.FoggyKitchenPublicSubnet[0].id]
    shape          = var.fk_shape
}

resource "oci_functions_function" "FoggyKitchenFn" {
    depends_on     = [null_resource.FoggyKitchenFnSetup,null_resource.FoggyKitchenMyFnSetup]
    application_id = var.use_my_fn_app ? var.my_fn_app_ocid : oci_functions_application.FoggyKitchenFnApp[0].id
    display_name   = var.fk_fn_name
    image          = "${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version}"
    memory_in_mbs  = var.memory_in_mbs
    config         = var.fn_config
}
