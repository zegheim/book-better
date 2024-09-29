
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

variable "slot_1" {
  description = "Slot 1 configuration. See terraform.tfvars.example for more information"
  type = object({
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
  })
  sensitive = true
}

variable "slot_2" {
  description = "Slot 2 configuration. See terraform.tfvars.example for more information"
  type = object({
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
  })
  sensitive = true
}
