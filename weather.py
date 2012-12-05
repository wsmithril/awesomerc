#! /usr/bin/python
# -*- coding=utf-8 -*-

import urllib, sys
from xml.dom.minidom import parse

class weather_provider(object):
    def __init__(self, city_id = None):
        self.city_id = city_id

    def _get_url(self):
        raise Exception

    def get_weather(self):
        raise Exception

def degree_NESW(d):
    # wind direction to compass direction
    return ["N", "NNE", "NE", "ENE",
            "E", "ESE", "SE", "SSE",
            "S", "SSW", "SW", "WSW",
            "W", "WNW", "NW", "NNW"][int((d + 360.0 / 32) % 360 / (360.0 / 16))]

class yahoo_weather(weather_provider):
    url = "http://weather.yahooapis.com/forecastrss?u=c&w="
    ns  = "http://xml.weather.yahoo.com/ns/rss/1.0"

    def _get_url(self):
        return self.url + self.city_id

    def get_weather(self):
        try:
            dom = parse(urllib.urlopen(self._get_url()))
        except Exception as e:
            return "None"

        resp = {}

        resp["location"]   = dom.getElementsByTagNameNS(self.ns, 'location')[0].getAttribute('city')
        resp["condition"]  = dom.getElementsByTagNameNS(self.ns, 'condition')[0].getAttribute('text')
        resp["temp"]       = dom.getElementsByTagNameNS(self.ns, 'condition')[0].getAttribute('temp')
        resp["time"]       = dom.getElementsByTagNameNS(self.ns, 'condition')[0].getAttribute('date')
        resp["wind speed"] = dom.getElementsByTagNameNS(self.ns, 'wind')[0].getAttribute('speed')
        resp["wind dire"]  = dom.getElementsByTagNameNS(self.ns, 'wind')[0].getAttribute('direction')

        resp["wind dire"] = degree_NESW(int(resp["wind dire"]))

        return ("\n".join([
            " " + resp["location"] + " " + resp["condition"],
            "Temperature: " + resp["temp"] + u"°C",
            "Wind: " + resp["wind speed"] + "km/h " + resp["wind dire"] ])).encode("UTF-8")


if __name__ == "__main__":
    w = yahoo_weather(city_id = sys.argv[1])
    print w.get_weather()

