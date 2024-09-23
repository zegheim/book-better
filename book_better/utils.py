import datetime


def parse_time(time_string: str) -> datetime.time:
    return datetime.datetime.strptime(time_string, "%H%M").time()
