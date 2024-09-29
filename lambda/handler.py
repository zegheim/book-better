import datetime
import logging
import os
from typing import Any, Literal, TypedDict

from book_better.better.live_client import LiveBetterClient
from book_better.enums import BetterActivity, BetterVenue
from book_better.logging import log_function_inputs_and_outputs
from book_better.utils import parse_time


class LambdaResponse(TypedDict):
    status: Literal["success", "error"]
    message: str


@log_function_inputs_and_outputs
def lambda_handler(event: Any, context: Any) -> LambdaResponse:
    client = LiveBetterClient(
        username=os.environ["BETTER_USERNAME"], password=os.environ["BETTER_PASSWORD"]
    )
    activity_date = datetime.date.today() + datetime.timedelta(days=7)

    available_slots = client.get_available_slots_for(
        venue=BetterVenue(os.environ["BETTER_VENUE_SLUG"]),
        activity=BetterActivity(os.environ["BETTER_ACTIVITY_SLUG"]),
        activity_date=activity_date,
        start_time=parse_time(os.environ["BETTER_ACTIVITY_START_TIME"]),
        end_time=parse_time(os.environ["BETTER_ACTIVITY_END_TIME"]),
    )
    if not available_slots:
        logging.error(
            "Could not find any available slot",
            extra=dict(available_slots=available_slots),
        )
        return {
            "status": "error",
            "message": f"Could not find any available slot on {activity_date.strftime('%Y-%m-%d')}.",
        }

    order_id: int | None = None
    for slot in available_slots:
        try:
            cart = client.add_to_cart(slot)
            order_id = client.checkout_with_benefit(cart)
        except Exception:
            logging.error(
                "Could not book slot, will try booking the next available slot",
                exc_info=True,
                extra=dict(slot=slot),
            )
            continue
        else:
            break

    if order_id is None:
        logging.error(
            "Could not book any slot",
            extra=dict(available_slots=available_slots),
        )
        return {
            "status": "error",
            "message": f"Could not book any slot on {activity_date.strftime('%Y-%m-%d')}.",
        }

    return {
        "status": "success",
        "message": f"Successfully booked order {order_id}.",
    }
