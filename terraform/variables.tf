
variable "debug_mode" {
  description = "Whether or not to deploy the Lambda in debug mode"
  type        = bool
  default     = true
}

variable "activity_slugs" {
  description = "Mapping of days -> activity slugs. See book_better.enums.BetterActivity for accepted value"
  type = object({
    monday    = string
    tuesday   = string
    wednesday = string
    thursday  = string
    friday    = string
    saturday  = string
    sunday    = string
  })
}

variable "venue_slugs" {
  description = "Mapping of days -> venue slugs. See book_better.enums.BetterVenue for accepted value"
  type = object({
    monday    = string
    tuesday   = string
    wednesday = string
    thursday  = string
    friday    = string
    saturday  = string
    sunday    = string
  })
}

variable "slots" {
  description = "Map of slot configurations. Each slot gets username/password and weekday start/end times."
  type = map(object({
    username = string
    password = string
    start_times = object({
      monday    = string
      tuesday   = string
      wednesday = string
      thursday  = string
      friday    = string
      saturday  = string
      sunday    = string
    })
    end_times = object({
      monday    = string
      tuesday   = string
      wednesday = string
      thursday  = string
      friday    = string
      saturday  = string
      sunday    = string
    })
  }))
  sensitive = true
}
