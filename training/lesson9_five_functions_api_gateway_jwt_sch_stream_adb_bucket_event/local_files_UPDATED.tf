## FnInitiator localfiles

data "local_file" "fninitiator_dockerfile" {
  filename = "${path.module}/functions/fninitiator/Dockerfile"
}

data "local_file" "fninitiator_func_py" {
  filename = "${path.module}/functions/fninitiator/func.py"
}

data "local_file" "fninitiator_func_yaml" {
  filename = "${path.module}/functions/fninitiator/func.yaml"
}

data "local_file" "fninitiator_requirements_txt" {
  filename = "${path.module}/functions/fninitiator/requirements.txt"
}

## FnCollector localfiles

data "local_file" "fncollector_dockerfile" {
  filename = "${path.module}/functions/fncollector/Dockerfile"
}

data "local_file" "fncollector_func_py" {
  filename = "${path.module}/functions/fncollector/func.py"
}

data "local_file" "fncollector_func_yaml" {
  filename = "${path.module}/functions/fncollector/func.yaml"
}

data "local_file" "fncollector_requirements_txt" {
  filename = "${path.module}/functions/fncollector/requirements.txt"
}

## FnADBSetup localfiles

data "local_file" "fnadbsetup_dockerfile" {
  filename = "${path.module}/functions/fnadbsetup/Dockerfile"
}

data "local_file" "fnadbsetup_func_py" {
  filename = "${path.module}/functions/fnadbsetup/func.py"
}

data "local_file" "fnadbsetup_func_yaml" {
  filename = "${path.module}/functions/fnadbsetup/func.yaml"
}

data "local_file" "fnadbsetup_requirements_txt" {
  filename = "${path.module}/functions/fnadbsetup/requirements.txt"
}

## FnJWTAuth localfiles

data "local_file" "fnjwtauth_dockerfile" {
  filename = "${path.module}/functions/fnjwtauth/Dockerfile"
}

data "local_file" "fnjwtauth_func_py" {
  filename = "${path.module}/functions/fnjwtauth/func.py"
}

data "local_file" "fnjwtauth_func_yaml" {
  filename = "${path.module}/functions/fnjwtauth/func.yaml"
}

data "local_file" "fnjwtauth_requirements_txt" {
  filename = "${path.module}/functions/fnjwtauth/requirements.txt"
}

## FnBulkLoad localfiles

data "local_file" "fnbulkload_dockerfile" {
  filename = "${path.module}/functions/fnbulkload/Dockerfile"
}

data "local_file" "fnbulkload_func_py" {
  filename = "${path.module}/functions/fnbulkload/func.py"
}

data "local_file" "fnbulkload_func_yaml" {
  filename = "${path.module}/functions/fnbulkload/func.yaml"
}

data "local_file" "fnbulkload_requirements_txt" {
  filename = "${path.module}/functions/fnbulkload/requirements.txt"
}