# book-better

Serverless bot to book activities on [Better UK](https://www.better.org.uk/). Powered by [AWS Lambda](https://aws.amazon.com/lambda/) and [Amazon EventBridge Scheduler](https://aws.amazon.com/eventbridge/scheduler/).

Currently only supports booking via benefits (e.g. the discontinued Better Racquets membership which allows you to book one court per day for free), but the code can be easily extended to also support booking via credits.

# Pre-requisites

- [Terraform](https://www.terraform.io/) (tested on v.1.9.5)
- [Amazon Web Services (AWS) Free Tier](https://aws.amazon.com/free/) account with [CLI v2 installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- [Better UK](https://www.better.org.uk/) with an appropriate membership type (e.g. Better Racquets).
- [Poetry](https://python-poetry.org/) (tested on v1.7.1)

# Installation

1. `git clone` this project.
1. `cd` into `<path-to-project>/book-better/terraform`.
1. Run `cp terraform.tfvars.example terraform.tfvars` to create a copy of a [variable definition](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files) file.
1. Open `terraform.tfvars` using your favourite text editor, and configure:

   - `activity_slugs`: Maps each day to the activity slug (e.g., "badminton-40min"). You can find these in the URL when browsing activities on [Better UK](https://bookings.better.org.uk/).
   - `venue_slugs`: Maps each day to the venue slug. You can find these in the URL when selecting a venue.
   - `slots`: Define one or more booking slots with credentials, start times, and end times. See [Configuration](#configuration) for details.
   - `debug_mode`: Set to `false` in production to suppress verbose logging.

   For a detailed breakdown of all configuration options, refer to [Configuration](#configuration).

1. Run `terraform init` to install all necessary Terraform providers.
1. Run `terraform apply -var-file='terraform.tfvars'`, and follow the prompts as instructed.
1. Verify your installation by running `aws lambda invoke --function-name=$(terraform output -raw lambda_name_slot_1) response.json` and inspect `response.json` using your favourite text editor. You should see something like

   ```
   {"status": "error", "message": "Could not find any available slot on 2024-09-30."}
   ```

# Configuration

This project uses a **data-driven slots architecture** to support multiple booking times without code duplication. Instead of creating separate infrastructure for each time slot, you define all your booking slots in a single configuration map.

## Global Settings

| Variable              | Description                                                                                                                                                           |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `debug_mode`          | When `true`, logs verbose booking attempt details. Set to `false` in production to reduce log output.                                                               |
| `activity_slugs`      | Map of day names (lowercase) to activity slugs (e.g., `"badminton-40min"`). Find slugs by visiting an activity on [Better UK](https://bookings.better.org.uk/).  |
| `venue_slugs`         | Map of day names (lowercase) to venue slugs. Find slugs by visiting a venue on [Better UK](https://bookings.better.org.uk/) and inspecting the URL.                |

## Slots

The `slots` variable defines one or more booking slots. Each slot represents a separate AWS Lambda function and EventBridge Scheduler rule. A typical configuration might have 2–3 slots to cover your preferred booking times.

### Slot Structure

Each slot requires:
- `username`: Better UK account username/email
- `password`: Better UK account password  
- `start_times`: Optional map of days to start times (HHMM format, e.g., `"2040"` for 8:40 PM)
- `end_times`: Optional map of days to end times (HHMM format)

**Key features:**
- Days and times are **optional**: only specify the days you want to book on. Days not listed are skipped.
- Times must match your desired activity slot exactly (as shown on Better UK).
- Each day can have a different start/end time combination across slots.

### Example: Two-Slot Configuration

```hcl
slots = {
  slot_1 = {
    username = "user1@example.com"
    password = "mypassword"
    start_times = {
      monday    = "0940"
      wednesday = "0940"
      friday    = "0940"
    }
    end_times = {
      monday    = "1020"
      wednesday = "1020"
      friday    = "1020"
    }
  }
  slot_2 = {
    username = "user1@example.com"
    password = "mypassword"
    start_times = {
      monday    = "1020"
      wednesday = "1020"
      friday    = "1020"
    }
    end_times = {
      monday    = "1100"
      wednesday = "1100"
      friday    = "1100"
    }
  }
}
```

This configuration creates:
- **slot_1**: Books Monday/Wednesday/Friday at 9:40–10:20 AM
- **slot_2**: Books Monday/Wednesday/Friday at 10:20–11:00 AM

### Example: Tuesday/Thursday-Only Slot

You don't need to specify all seven days. This slot books only on Tuesday and Thursday:

```hcl
slots = {
  slot_3 = {
    username = "user3@example.com"
    password = "anotherpassword"
    start_times = {
      tuesday   = "1900"
      thursday  = "1900"
    }
    end_times = {
      tuesday   = "2000"
      thursday  = "2000"
    }
  }
}
```

### Notes

- Activity and venue slugs are shared across all slots (see `activity_slugs` and `venue_slugs` above).
- Each slot uses separate AWS Lambda credentials; they run independently.
- Adding a new slot is as simple as adding another key-value pair to the `slots` map—no code changes required.

# Developing locally

1. `git clone` this project.
1. `cd` into `<path-to-project>/book-better`.
1. Run `cp .env.example .env` to create a copy of the environment variables configuration. Refer to [Configuration](#configuration) for what each individual variables mean (hopefully they're self-explanatory enough!).
1. Run `poetry install` to install the `book_better` project along its dependencies in a virtual environment.
1. Run `poetry run main` to run the entrypoint (located at `book_better.main:main`).