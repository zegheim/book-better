import datetime
import logging
import os

from dotenv import load_dotenv

from book_better.better.live_client import LiveBetterClient
from book_better.enums import BetterActivity, BetterVenue
from book_better.utils import parse_time

ACTIVITY_DATE = datetime.date(2024, 9, 27)

logging.basicConfig(level=logging.DEBUG, handlers=[logging.StreamHandler()])

load_dotenv()


def main():
    client = LiveBetterClient(
        username=os.environ["BETTER_USERNAME"], password=os.environ["BETTER_PASSWORD"]
    )

    available_slots = client.get_available_slots_for(
        venue=BetterVenue(os.environ["BETTER_VENUE_SLUG"]),
        activity=BetterActivity(os.environ["BETTER_ACTIVITY_SLUG"]),
        activity_date=ACTIVITY_DATE,
        start_time=parse_time(os.environ["BETTER_ACTIVITY_START_TIME"]),
        end_time=parse_time(os.environ["BETTER_ACTIVITY_END_TIME"]),
    )
    if not available_slots:
        logging.error(
            "Could not find any available slot",
            extra=dict(available_slots=available_slots),
        )
        return

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
        return

    return order_id
