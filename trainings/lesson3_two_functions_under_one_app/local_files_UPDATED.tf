
# FnCustom1

data "local_file" "fncustom1_dockerfile" {
  filename = "${path.module}/functions/fncustom1/Dockerfile"
}

data "local_file" "fncustom1_func_py" {
  filename = "${path.module}/functions/fncustom1/func.py"
}

data "local_file" "fncustom1_func_yaml" {
  filename = "${path.module}/functions/fncustom1/func.yaml"
}

data "local_file" "fncustom1_requirements_txt" {
  filename = "${path.module}/functions/fncustom1/requirements.txt"
}

# FnCustom2

data "local_file" "fncustom2_dockerfile" {
  filename = "${path.module}/functions/fncustom2/Dockerfile"
}

data "local_file" "fncustom2_func_py" {
  filename = "${path.module}/functions/fncustom2/func.py"
}

data "local_file" "fncustom2_func_yaml" {
  filename = "${path.module}/functions/fncustom2/func.yaml"
}

data "local_file" "fncustom2_requirements_txt" {
  filename = "${path.module}/functions/fncustom2/requirements.txt"
}