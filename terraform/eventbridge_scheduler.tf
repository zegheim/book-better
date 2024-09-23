data "aws_iam_policy_document" "eventbridge_scheduler_assume_role_policy_document" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eventbridge_scheduler_execution_role" {
  name               = "${var.lambda_name}-SchedulerExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_scheduler_assume_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "allow_eventbridge_scheduler_to_execute_lambda" {
  role       = aws_iam_role.eventbridge_scheduler_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

resource "aws_scheduler_schedule" "execute_lambda_on_schedule" {
  name = "${var.lambda_name}-SchedulerExecution"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.eventbridge_scheduler_schedule_expression
  schedule_expression_timezone = "Europe/London"

  target {
    arn      = aws_lambda_function.book_better_bot.arn
    role_arn = aws_iam_role.eventbridge_scheduler_execution_role.arn

    retry_policy {
      maximum_retry_attempts = 0
    }
  }
}
