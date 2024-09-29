import datetime
import logging
import os
import time
from typing import Any, Literal, TypedDict

import zoneinfo

from book_better.better.live_client import LiveBetterClient
from book_better.enums import BetterActivity, BetterVenue
from book_better.logging import log_function_inputs_and_outputs
from book_better.utils import parse_time

MAX_WAIT_TIME_IN_SECS = 2 * 60


class LambdaResponse(TypedDict):
    status: Literal["success", "error"]
    message: str


def _sleep_until(booking_time: datetime.time, tzinfo: datetime.tzinfo) -> None:
    booking_datetime = datetime.datetime.combine(
        datetime.datetime.today(),
        booking_time,
        tzinfo=tzinfo,
    )
    now_datetime = datetime.datetime.now(tz=tzinfo)
    assert (booking_datetime - now_datetime).seconds <= MAX_WAIT_TIME_IN_SECS

    while datetime.datetime.now(tz=tzinfo).time() < booking_time:
        time.sleep(1.0)


@log_function_inputs_and_outputs
def lambda_handler(event: Any, context: Any) -> LambdaResponse:
    client = LiveBetterClient(
        username=os.environ["BETTER_USERNAME"],
        password=os.environ["BETTER_PASSWORD"],
    )
    logging.info(
        "Pre-authenticating before busy wait",
        extra=dict(membership_user_id=client.membership_user_id),
    )

    _sleep_until(
        booking_time=parse_time(f"{os.environ['BETTER_BOOKING_HOUR_24H']}00"),
        tzinfo=zoneinfo.ZoneInfo(os.environ["BETTER_BOOKING_TZ"]),  # type: ignore
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
