#!/usr/bin/env python3
"""
Sample to setup holidays for this year and then calculate how many working days have elapsed since a given date.
"""
import numpy as np
import datetime as dt
import sys

HOLIDAYS = [
    "2020-01-01",
    "2020-02-21",
    "2020-04-10",
    "2020-05-01",
    "2020-05-25",
    "2020-07-31",
    "2020-10-02",
    "2020-10-26",
    "2020-11-16",
    "2020-12-25",
]
DEFAULT_START = dt.date(2020, 5, 1)


def get_year_month_week_day(days):
    year = int(days / 365)
    days = days % 365
    month = int(days / 30)
    days = days % 30
    week = int(days / 7)
    day = days % 7
    return year, month, week, day


def gets_year_month_week_day(days):
    y, m, w, d = get_year_month_week_day(days)
    return f"""{y}yr {m}mo {w}wk {d}dys"""


if __name__ == "__main__":

    if len(sys.argv) > 1:
        start = dt.datetime.strptime(sys.argv[1], "%Y-%m-%d").date()
    else:
        start = DEFAULT_START

    end = dt.date.today()  # - dt.timedelta(days=1)
    HOLIDAYS = np.array(HOLIDAYS, dtype="datetime64")

    start = np.datetime64(start)
    end = np.datetime64(end)

    # weekmask for working_days is set as saturday and sunday as not working;
    # add our holiday list too to the mix
    working_days = int(
        np.busday_count(start, end, weekmask="1111100", holidays=HOLIDAYS)
    )
    days = int(np.busday_count(start, end, weekmask="1111111"))
    sdays = gets_year_month_week_day(days)

    if days < 0 or working_days < 0:
        print(f"""{working_days} workdays; {days} days till {start} \n ({sdays})""")
    else:
        print(f"""{working_days} workdays; {days} days since {start} \n ({sdays})""")
