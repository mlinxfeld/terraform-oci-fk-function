resource "oci_artifacts_container_repository" "FoggyKitchenOCIR" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.ocir_repo_name}/${var.fk_fn_name}"
  is_public      = false
}

resource "null_resource" "FoggyKitchenFnSetup" {
  count      = var.use_my_fn ? 0 : 1
  depends_on = [oci_functions_application.FoggyKitchenFnApp, oci_artifacts_container_repository.FoggyKitchenOCIR]

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${local.ocir_docker_repository} --username ${local.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }

  provisioner "local-exec" {
    command = "docker image rm ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version} -f || true"
  }

  provisioner "local-exec" {
    command     = "docker build -t ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version} ."
    working_dir = local.fn_source_dir
  }

  provisioner "local-exec" {
    command     = "docker push ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version}"
    working_dir = local.fn_source_dir
  }

}

resource "local_file" "dockerfile_content" {
  count    = var.use_my_fn ? 1 : 0
  content  = var.dockerfile_content
  filename = "${local.fn_source_dir}/Dockerfile"
}

resource "local_file" "func_py_content" {
  count    = var.use_my_fn ? 1 : 0
  content  = var.func_py_content
  filename = "${local.fn_source_dir}/func.py"
}

resource "local_file" "func_yaml_content" {
  count    = var.use_my_fn ? 1 : 0
  content  = var.func_yaml_content
  filename = "${local.fn_source_dir}/func.yaml"
}

resource "local_file" "requirements_txt_content" {
  count    = var.use_my_fn ? 1 : 0
  content  = var.requirements_txt_content
  filename = "${local.fn_source_dir}/requirements.txt"
}

resource "local_file" "extra_files" {
  for_each = var.use_my_fn ? var.extra_files : {}
  content  = each.value
  filename = "${local.fn_source_dir}/${each.key}"
}

resource "null_resource" "FoggyKitchenMyFnSetup" {
  count      = var.use_my_fn ? 1 : 0
  depends_on = [oci_functions_application.FoggyKitchenFnApp, oci_artifacts_container_repository.FoggyKitchenOCIR, local_file.dockerfile_content, local_file.func_py_content, local_file.func_yaml_content, local_file.requirements_txt_content, local_file.extra_files]

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${local.ocir_docker_repository} --username ${local.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }

  provisioner "local-exec" {
    command = "docker image rm ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version} -f || true"
  }

  provisioner "local-exec" {
    command     = "docker build -t ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version} ."
    working_dir = local.fn_source_dir
  }

  provisioner "local-exec" {
    command     = "docker push ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version}"
    working_dir = local.fn_source_dir
  }

}
