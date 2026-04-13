resource "aws_lambda_function" "booking_lambda" {
  for_each = local.slot_day_keys

  function_name    = "${local.lambda_name}-${title(each.value.day)}-${each.value.start_time}-${each.value.end_time}"
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
      BETTER_USERNAME            = var.slots[each.value.slot_name].username
      BETTER_PASSWORD            = var.slots[each.value.slot_name].password
      BETTER_ACTIVITY_SLUG       = each.value.activity_slug
      BETTER_ACTIVITY_START_TIME = each.value.start_time
      BETTER_ACTIVITY_END_TIME   = each.value.end_time
      BETTER_VENUE_SLUG          = each.value.venue_slug
      DEBUG_MODE                 = var.debug_mode ? "1" : ""
    }
  }
}

resource "aws_scheduler_schedule" "booking_schedule" {
  for_each = local.slot_day_keys

  name = aws_lambda_function.booking_lambda[each.key].function_name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = local.cron_schedules[each.value.day]
  schedule_expression_timezone = local.cron_schedule_tz

  target {
    arn      = aws_lambda_function.booking_lambda[each.key].arn
    role_arn = aws_iam_role.eventbridge_scheduler_execution_role.arn

    retry_policy {
      maximum_retry_attempts = 0
    }
  }
}
