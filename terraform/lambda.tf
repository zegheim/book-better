data "aws_iam_policy_document" "lambda_assume_role_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${local.lambda_name}-LambdaExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "allow_lambda_to_log_to_cloudwatch" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_layer_version" "book_better_bot" {
  filename            = data.archive_file.layers_zip.output_path
  description         = "Contains all external dependencies needed for ${local.lambda_name} to run."
  layer_name          = "${local.lambda_name}-dependencies"
  compatible_runtimes = [local.lambda_runtime]
}

