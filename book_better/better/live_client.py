from __future__ import annotations

import datetime
import functools
import logging
from collections.abc import Callable
from typing import Concatenate

import requests
from requests.adapters import HTTPAdapter
from requests_toolbelt.sessions import BaseUrlSession  # type: ignore
from urllib3.util import Retry

from book_better.enums import BetterActivity, BetterVenue
from book_better.logging import log_method_inputs_and_outputs
from book_better.models import (
    ActivityCart,
    ActivitySlot,
    ActivityTime,
)

type _LiveBetterClientInstanceMethod[**P, R] = Callable[
    Concatenate[LiveBetterClient, P], R
]


def _requires_authentication[**P, R](
    func: _LiveBetterClientInstanceMethod[P, R],
) -> _LiveBetterClientInstanceMethod[P, R]:
    @functools.wraps(func)
    def wrapper(self: LiveBetterClient, *args: P.args, **kwargs: P.kwargs) -> R:
        if not self.authenticated:
            logging.info(
                "requires_authentication: client is not authenticated, will authenticate"
            )
            self.authenticate()
        return func(self, *args, **kwargs)

    return wrapper


class LiveBetterClient:
    HEADERS = {
        "Origin": "https://bookings.better.org.uk",
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:131.0) Gecko/20100101 Firefox/131.0",
    }

    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password

        self.session: requests.Session = BaseUrlSession(
            base_url="https://better-admin.org.uk/api/"
        )
        self.session.headers.update(self.HEADERS)
        self.session.mount(
            "https://",
            HTTPAdapter(
                max_retries=Retry(
                    total=3,
                    backoff_factor=2,
                    status_forcelist=[429, 500, 502, 503, 504],
                )
            ),
        )

    @property
    @log_method_inputs_and_outputs
    def authenticated(self) -> bool:
        return bool(self.session.headers.get("Authorization"))

    @functools.cached_property
    @_requires_authentication
    @log_method_inputs_and_outputs
    def membership_user_id(self) -> int:
        response = self.session.get("auth/user")
        response.raise_for_status()

        return response.json()["data"]["membership_user"]["id"]

    @log_method_inputs_and_outputs
    def authenticate(self) -> None:
        auth_response = self.session.post(
            "auth/customer/login",
            json=dict(username=self.username, password=self.password),
        )
        auth_response.raise_for_status()

        token: str = auth_response.json()["token"]
        self.session.headers.update({"Authorization": f"Bearer {token}"})

    @_requires_authentication
    @log_method_inputs_and_outputs
    def get_available_slots_for(
        self,
        venue: BetterVenue,
        activity: BetterActivity,
        activity_date: datetime.date,
        start_time: datetime.time,
        end_time: datetime.time,
    ) -> list[ActivitySlot]:
        response = self.session.get(
            f"activities/venue/{venue.value}/activity/{activity.value}/slots",
            params={
                "date": activity_date.strftime("%Y-%m-%d"),
                "start_time": start_time.strftime("%H:%M"),
                "end_time": end_time.strftime("%H:%M"),
            },
        )
        response.raise_for_status()

        return [
            ActivitySlot(
                id=slot["id"],
                location_id=slot["location"]["id"],
                pricing_option_id=slot["pricing_option_id"],
                restriction_ids=slot["restriction_ids"],
                name=slot["location"]["slug"],
                cart_type=slot["cart_type"],
            )
            for slot in response.json()["data"]
            if slot["spaces"] > 0
            and slot["booking"] is None
            and slot["benefit_available"] is not None
        ]

    @_requires_authentication
    @log_method_inputs_and_outputs
    def get_available_times_for(
        self, venue: BetterVenue, activity: BetterActivity, activity_date: datetime.date
    ) -> list[ActivityTime]:
        response = self.session.get(
            f"activities/venue/{venue.value}/activity/{activity.value}/times",
            params={"date": activity_date.strftime("%Y-%m-%d")},
        )
        response.raise_for_status()

        return [
            ActivityTime(
                start=datetime.datetime.strptime(
                    time_["starts_at"]["format_24_hour"], "%H:%M"
                ).time(),
                end=datetime.datetime.strptime(
                    time_["ends_at"]["format_24_hour"], "%H:%M"
                ).time(),
            )
            for time_ in response.json()["data"]
            if time_["spaces"] > 0 and time_["booking"] is None
        ]

    @_requires_authentication
    @log_method_inputs_and_outputs
    def add_to_cart(self, slot: ActivitySlot) -> ActivityCart:
        response = self.session.post(
            "activities/cart/add",
            json=dict(
                items=[
                    dict(
                        activity_restriction_ids=slot.restriction_ids,
                        apply_benefit=True,
                        id=slot.id,
                        pricing_option_id=slot.pricing_option_id,
                        type=slot.cart_type,
                    )
                ],
                membership_user_id=self.membership_user_id,
                selected_user_id=None,
            ),
        )
        response.raise_for_status()

        data = response.json()["data"]

        return ActivityCart(
            id=data["id"],
            amount=data["total"],
            source=data["source"],
        )

    @_requires_authentication
    @log_method_inputs_and_outputs
    def checkout_with_benefit(self, cart: ActivityCart) -> int:
        complete_checkout_response = self.session.post(
            "checkout/complete",
            json=dict(
                completed_waivers=[],
                payments=[],
                selected_user_id=None,
                source=cart.source,
                terms=[1],
            ),
        )
        complete_checkout_response.raise_for_status()

        return complete_checkout_response.json()["complete_order_id"]
