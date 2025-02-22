import enum


class BetterVenue(str, enum.Enum):
    leytonstone = "leytonstone-leisure-centre"
    newham = "newham-leisure-centre"
    walthamstow = "walthamstow-leisure-centre"
    copper_box = "copper-box-arena"


class BetterActivity(str, enum.Enum):
    badminton_40_mins = "badminton-40min"
