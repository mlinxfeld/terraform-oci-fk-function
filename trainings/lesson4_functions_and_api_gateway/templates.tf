data "template_file" "custom_fn_dockerfile_template" {
  template = file("${path.module}/templates/Dockerfile.template")

  vars = {
  }
}


data "template_file" "custom_fn_func_py_template1" {
  template = file("${path.module}/templates/func.py.template")

  vars = {
    fn_custom_message = "Here is function fncustom1"
  }
}

data "template_file" "custom_fn_func_py_template2" {
  template = file("${path.module}/templates/func.py.template")

  vars = {
    fn_custom_message = "Here is function fncustom2"
  }
}

data "template_file" "custom_fn_func_yaml_template1" {
  template = file("${path.module}/templates/func.yaml.template")

  vars = {
    fn_name = "fncustom1"
  }
}

data "template_file" "custom_fn_func_yaml_template2" {
  template = file("${path.module}/templates/func.yaml.template")

  vars = {
    fn_name = "fncustom2"
  }
}

data "template_file" "requirements_txt_content" {
  template = file("${path.module}/templates/requirements.txt.template")

  vars = {
  }
}