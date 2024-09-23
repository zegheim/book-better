resource "null_resource" "build_lambda" {
  triggers = {
    book_better_md5  = md5(join("", [for file in fileset("../book_better", "**") : filemd5("../book_better/${file}")]))
    lambda_md5       = md5(join("", [for file in fileset("../lambda", "**") : filemd5("../lambda/${file}")]))
    build_script_md5 = filemd5("../build_scripts/build_lambda.sh")
  }

  provisioner "local-exec" {
    command     = "../build_scripts/build_lambda.sh"
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
}

resource "null_resource" "build_layers" {
  triggers = {
    pyproject_toml_md5 = filemd5("../pyproject.toml")
    build_script_md5   = filemd5("../build_scripts/build_layers.sh")
  }

  provisioner "local-exec" {
    command     = "../build_scripts/build_layers.sh"
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../build_output/lambda"
  output_path = "../build_output/${var.project_name}.zip"
  depends_on  = [null_resource.build_lambda]
}

data "archive_file" "layers_zip" {
  type        = "zip"
  source_dir  = "../build_output/layers"
  output_path = "../build_output/${var.project_name}-dependencies.zip"
  excludes    = ["__pycache__", "core/__pycache"]
  depends_on  = [null_resource.build_layers]
}
