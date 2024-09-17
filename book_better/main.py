import datetime
import os

from dotenv import load_dotenv

from book_better.better.live_client import LiveBetterClient
from book_better.enums import BetterActivity, BetterVenue

load_dotenv()


def main():
    client = LiveBetterClient(
        username=os.environ["BETTER_USERNAME"], password=os.environ["BETTER_PASSWORD"]
    )
    client.authenticate()

    available_times = client.get_available_times_for(
        venue=BetterVenue.leytonstone,
        activity=BetterActivity.badminton_40_mins,
        activity_date=datetime.date(2024, 9, 17),
    )
    available_slots = client.get_available_slots_for(
        venue=BetterVenue.leytonstone,
        activity=BetterActivity.badminton_40_mins,
        activity_date=datetime.date(2024, 9, 17),
        start_time=available_times[-1].start,
        end_time=available_times[-1].end,
    )
    cart = client.add_to_cart(available_slots[0])
    order_id = client.checkout_with_credit(cart)

    print(order_id)
