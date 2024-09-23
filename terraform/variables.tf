variable "aws_profile" {
  description = "AWS CLI profile to use (see ~/.aws/config)"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Name of this project. Used across the codebase as identifiers"
  type        = string
  default     = "book-better-bot"
}

variable "project_description" {
  description = "One sentence summary of this project. Used across the codebase as identifiers"
  type        = string
  default     = "Bot to book activities at Better-owned leisure centres."
}

variable "debug_mode" {
  description = "Whether or not to deploy the Lambda in debug mode"
  type        = bool
  default     = true
}

variable "lambda_handler" {
  description = "Entrypoint for the Lambda function"
  type        = string
  default     = "lambda.handler.lambda_handler"
}

variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "BookBetterBot"
}

variable "lambda_runtime" {
  description = "What language and version to run Lambda function in"
  type        = string
  default     = "python3.12"
}

variable "eventbridge_scheduler_schedule_expression" {
  description = "When to run the Lambda function. See https://docs.aws.amazon.com/scheduler/latest/UserGuide/schedule-types.html#cron-based for more information."
  type        = string
}

variable "better_username" {
  description = "Better account username. Must have the 'Better Racquets' membership."
  type        = string
  sensitive   = true
}

variable "better_password" {
  description = "Better account password. Must have the 'Better Racquets' membership."
  type        = string
  sensitive   = true
}

variable "better_venue_slug" {
  description = "Better venue identifier. Refer to book_better.enums.BetterVenue for supported venues."
  type        = string
  default     = "leytonstone-leisure-centre"
}

variable "better_activity_slug" {
  description = "Better activity identifier. Refer to book_better.enums.BetterActivity for supported activities."
  type        = string
  default     = "badminton-40min"
}

variable "better_activity_start_time" {
  description = "Activity start time in HHMM format (e.g. 2000)"
  type        = string
}

variable "better_activity_end_time" {
  description = "Activity end time in HHMM format (e.g. 2040)"
  type        = string
}
