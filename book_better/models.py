import datetime
from dataclasses import dataclass


@dataclass
class ActivitySlot:
    id: int
    location_id: int
    pricing_option_id: int
    restriction_ids: list[int]
    name: str
    cart_type: str


@dataclass
class ActivityTime:
    start: datetime.time
    end: datetime.time


@dataclass
class ActivityCart:
    id: int
    amount: int
    source: str
