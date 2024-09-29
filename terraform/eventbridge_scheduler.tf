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
  name               = "${local.lambda_name}-SchedulerExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_scheduler_assume_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "allow_eventbridge_scheduler_to_execute_lambda" {
  role       = aws_iam_role.eventbridge_scheduler_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}
