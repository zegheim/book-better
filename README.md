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
1. Open `terraform.tfvars` using your favourite text editor, and modify the configuration as required. [Configuration](#configuration) for more information. In general, you should only need to modify the following variables:

   - `better_venue_slug`
   - `better_activity_slug`
   - `better_activity_start_time`
   - `better_activity_end_time`
   - `better_username`
   - `better_password`

1. Run `terraform init` to install all necessary Terraform providers.
1. Run `terraform apply -var-file='terraform.tfvars'`, and follow the prompts as instructed.
1. Verify your installation by running `aws lambda invoke --function-name=$(terraform output -raw lambda_name) response.json` and inspect `response.json` using your favourite text editor. You should see something like

   ```
   {"status": "error", "message": "Could not find any available slot on 2024-09-30."}
   ```

# Configuration

The defaults provided in `terraform.tfvars.example` will try and book next Monday's 8PM - 8.40PM Badminton 40min slot at [Leytonstone Leisure Centre](https://bookings.better.org.uk/location/leytonstone-leisure-centre/badminton-40min) every Monday at 10PM UK time. If this is not what you want, adjust the following configuration variables accordingly:

| Variable                                    | Description                                                                                                                                                                                                        |
|---------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `better_venue_slug`                         | The venue slug where you want to book an activity for. You can find it by visiting [Better UK](https://bookings.better.org.uk/), selecting your venue, and looking at the URL bar.                                 |
| `better_activity_slug`                      | The activity slug. You can find it by going to the booking page for the activity that you want and looking at the URL bar.                                                                                         |
| `better_activity_start_time`                | The start time of the slot that you want to book in HHMM format (e.g. 2120 for 9.20PM).                                                                                                                            |
| `better_activity_end_time`                  | The end time of the slot that you want to book in HHMM format (e.g. 2120 for 9.20PM).                                                                                                                              |
| `eventbridge_scheduler_schedule_expression` | When the bot should book the desired activity slot. See [Cron-based schedules](https://docs.aws.amazon.com/scheduler/latest/UserGuide/schedule-types.html#cron-based) for more information on the accepted syntax. |

# Developing locally

1. `git clone` this project.
1. `cd` into `<path-to-project>/book-better`.
1. Run `cp .env.example .env` to create a copy of the environment variables configuration. Refer to [Configuration](#configuration) for what each individual variables mean (hopefully they're self-explanatory enough!).
1. Run `poetry install` to install the `book_better` project along its dependencies in a virtual environment.
1. Run `poetry run main` to run the entrypoint (located at `book_better.main:main`).