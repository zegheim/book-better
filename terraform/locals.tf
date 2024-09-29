locals {
  aws_profile         = "default"
  aws_region          = "eu-west-2"
  lambda_name         = "BookBetterBot"
  lambda_handler      = "lambda.handler.lambda_handler"
  lambda_runtime      = "python3.12"
  project_name        = "book-better-bot"
  project_description = "Bot to book activities at Better-owned leisure centres."
}



locals {
  cron_booking_hour_24h = "22"
  cron_schedules = {
    monday    = "cron(59 ${local.cron_booking_hour_24h - 1} ? * 2 *)"
    tuesday   = "cron(59 ${local.cron_booking_hour_24h - 1} ? * 3 *)"
    wednesday = "cron(59 ${local.cron_booking_hour_24h - 1} ? * 4 *)"
    thursday  = "cron(59 ${local.cron_booking_hour_24h - 1} ? * 5 *)"
    friday    = "cron(59 ${local.cron_booking_hour_24h - 1} ? * 6 *)"
    saturday  = "cron(59 ${local.cron_booking_hour_24h - 1} ? * 7 *)"
    sunday    = "cron(59 ${local.cron_booking_hour_24h - 1} ? * 1 *)"
  }
  cron_schedule_tz = "Europe/London"
}

locals {
  slot_1 = {
    lambda_names = {
      monday    = "${local.lambda_name}-Monday-${var.slot_1.start_times.monday}-${var.slot_1.end_times.monday}"
      tuesday   = "${local.lambda_name}-Tuesday-${var.slot_1.start_times.tuesday}-${var.slot_1.end_times.tuesday}"
      wednesday = "${local.lambda_name}-Wednesday-${var.slot_1.start_times.wednesday}-${var.slot_1.end_times.wednesday}"
      thursday  = "${local.lambda_name}-Thursday-${var.slot_1.start_times.thursday}-${var.slot_1.end_times.thursday}"
      friday    = "${local.lambda_name}-Friday-${var.slot_1.start_times.friday}-${var.slot_1.end_times.friday}"
      saturday  = "${local.lambda_name}-Saturday-${var.slot_1.start_times.saturday}-${var.slot_1.end_times.saturday}"
      sunday    = "${local.lambda_name}-Sunday-${var.slot_1.start_times.sunday}-${var.slot_1.end_times.sunday}"
    }
  }
  slot_2 = {
    lambda_names = {
      monday    = "${local.lambda_name}-Monday-${var.slot_2.start_times.monday}-${var.slot_2.end_times.monday}"
      tuesday   = "${local.lambda_name}-Tuesday-${var.slot_2.start_times.tuesday}-${var.slot_2.end_times.tuesday}"
      wednesday = "${local.lambda_name}-Wednesday-${var.slot_2.start_times.wednesday}-${var.slot_2.end_times.wednesday}"
      thursday  = "${local.lambda_name}-Thursday-${var.slot_2.start_times.thursday}-${var.slot_2.end_times.thursday}"
      friday    = "${local.lambda_name}-Friday-${var.slot_2.start_times.friday}-${var.slot_2.end_times.friday}"
      saturday  = "${local.lambda_name}-Saturday-${var.slot_2.start_times.saturday}-${var.slot_2.end_times.saturday}"
      sunday    = "${local.lambda_name}-Sunday-${var.slot_2.start_times.sunday}-${var.slot_2.end_times.sunday}"
    }
  }
}
