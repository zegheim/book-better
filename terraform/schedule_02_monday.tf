resource "aws_scheduler_schedule" "book_on_monday_1" {
  name = local.slot_1.lambda_names.monday

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = local.cron_schedules.monday
  schedule_expression_timezone = local.cron_schedule_tz

  target {
    arn      = aws_lambda_function.book_on_monday_1.arn
    role_arn = aws_iam_role.eventbridge_scheduler_execution_role.arn

    retry_policy {
      maximum_retry_attempts = 0
    }
  }
}

resource "aws_lambda_function" "book_on_monday_1" {
  function_name    = local.slot_1.lambda_names.monday
  description      = local.project_description
  filename         = data.archive_file.lambda_zip.output_path
  runtime          = local.lambda_runtime
  handler          = local.lambda_handler
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
      BETTER_BOOKING_HOUR_24H    = local.cron_booking_hour_24h
      BETTER_BOOKING_TZ          = local.cron_schedule_tz
      BETTER_USERNAME            = var.slot_1.username
      BETTER_PASSWORD            = var.slot_1.password
      BETTER_ACTIVITY_SLUG       = var.activity_slugs.monday
      BETTER_ACTIVITY_START_TIME = var.slot_1.start_times.monday
      BETTER_ACTIVITY_END_TIME   = var.slot_1.end_times.monday
      BETTER_VENUE_SLUG          = var.venue_slugs.monday
      DEBUG_MODE                 = var.debug_mode ? "1" : ""
    }
  }
}

resource "aws_scheduler_schedule" "book_on_monday_2" {
  name = local.slot_2.lambda_names.monday

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = local.cron_schedules.monday
  schedule_expression_timezone = local.cron_schedule_tz

  target {
    arn      = aws_lambda_function.book_on_monday_2.arn
    role_arn = aws_iam_role.eventbridge_scheduler_execution_role.arn

    retry_policy {
      maximum_retry_attempts = 0
    }
  }
}

resource "aws_lambda_function" "book_on_monday_2" {
  function_name    = local.slot_2.lambda_names.monday
  description      = local.project_description
  filename         = data.archive_file.lambda_zip.output_path
  runtime          = local.lambda_runtime
  handler          = local.lambda_handler
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
      BETTER_BOOKING_HOUR_24H    = local.cron_booking_hour_24h
      BETTER_BOOKING_TZ          = local.cron_schedule_tz
      BETTER_USERNAME            = var.slot_2.username
      BETTER_PASSWORD            = var.slot_2.password
      BETTER_ACTIVITY_SLUG       = var.activity_slugs.monday
      BETTER_ACTIVITY_START_TIME = var.slot_2.start_times.monday
      BETTER_ACTIVITY_END_TIME   = var.slot_2.end_times.monday
      BETTER_VENUE_SLUG          = var.venue_slugs.monday
      DEBUG_MODE                 = var.debug_mode ? "1" : ""
    }
  }
}
