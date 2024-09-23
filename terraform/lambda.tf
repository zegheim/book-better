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
  name               = "${var.lambda_name}-LambdaExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "allow_lambda_to_log_to_cloudwatch" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "book_better_bot" {
  function_name    = var.lambda_name
  description      = var.project_description
  filename         = data.archive_file.lambda_zip.output_path
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
  layers           = [aws_lambda_layer_version.book_better_bot.arn]
  timeout          = 120

  logging_config {
    log_format            = "JSON"
    application_log_level = var.debug_mode ? "DEBUG" : "INFO"
    system_log_level      = var.debug_mode ? "DEBUG" : "INFO"
  }

  depends_on = [
    aws_iam_role_policy_attachment.allow_lambda_to_log_to_cloudwatch
  ]

  environment {
    variables = {
      BETTER_USERNAME            = var.better_username
      BETTER_PASSWORD            = var.better_password
      BETTER_ACTIVITY_SLUG       = var.better_activity_slug
      BETTER_ACTIVITY_START_TIME = var.better_activity_start_time
      BETTER_ACTIVITY_END_TIME   = var.better_activity_end_time
      BETTER_VENUE_SLUG          = var.better_venue_slug
      DEBUG_MODE                 = var.debug_mode ? "1" : ""
    }
  }
}

resource "aws_lambda_layer_version" "book_better_bot" {
  filename            = data.archive_file.layers_zip.output_path
  description         = "Contains all external dependencies needed for ${var.lambda_name} to run."
  layer_name          = "${var.lambda_name}-dependencies"
  compatible_runtimes = [var.lambda_runtime]
}

