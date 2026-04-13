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
  days_of_the_week = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
  ]

  # Non-sensitive map for for_each iteration (excludes username/password)
  slot_day_keys = merge([
    for slot_name, slot in var.slots : {
      for day in local.days_of_the_week : "${slot_name}-${day}" => {
        slot_name     = slot_name
        day           = day
        start_time    = slot.start_times[day]
        end_time      = slot.end_times[day]
        activity_slug = var.activity_slugs[day]
        venue_slug    = var.venue_slugs[day]
      }
      # Only create a slot/day pair if both start_times and end_times are specified for this day
      if slot.start_times != null && slot.end_times != null &&
      contains(keys(slot.start_times), day) &&
      contains(keys(slot.end_times), day)
    }
  ]...)
}
