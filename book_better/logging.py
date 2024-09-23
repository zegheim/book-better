import functools
import json
import logging
from collections.abc import Callable
from typing import Any, Concatenate

type InstanceMethod[**P, R] = Callable[Concatenate[Any, P], R]


def _hacky_sanitise(o: Any) -> Any:
    """See https://stackoverflow.com/a/36142844"""
    return json.loads(json.dumps(o, default=str))


def log_method_inputs_and_outputs[**P, R](
    method: InstanceMethod[P, R],
) -> InstanceMethod[P, R]:
    @functools.wraps(method)
    def wrapper(self: Any, *args: P.args, **kwargs: P.kwargs):
        method_name = method.__qualname__
        logging.info(
            f"{method_name}: input(s)",
            extra=dict(
                method_args=_hacky_sanitise(args),
                method_kwargs=_hacky_sanitise(kwargs),
            ),
        )
        result = method(self, *args, **kwargs)
        logging.info(
            f"{method_name}: output(s)",
            extra=dict(
                result=_hacky_sanitise(result),
            ),
        )
        return result

    return wrapper
