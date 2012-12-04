#! /usr/bin/python
# -*- coding: utf-8 -*-

import urllib, sys
from xml.dom.minidom import parse

class weather_provider(object):
    def __init__(self, city_id = None):
        self.city_id = city_id

    def _get_url(self):
        raise Exception

    def get_weather(self):
        raise Exception

def degree_NEWS(d):
    # wind direction to NSWE notion
    d1  = "NEWS"[(d + 46) / 90 % 4]
    d2  = "NEWS"[(d + 23) / 90 % 4]
    d3  = "NEWS"[(d + 12) / 90 % 4]
    if (d1 == d2 and d2 == d3):
        return d1
    elif (d2 == d3):
        return d1 + d2
    else:
        return d1 + d2 + d3

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

        resp["wind dire"] = degree_NEWS(int(resp["wind dire"]))

        return "\n".join([
            " " + resp["location"] + " " + resp["condition"],
            "Temperature: " + resp["temp"] + " C",
            "Wind: " + resp["wind speed"] + "km/h " + resp["wind dire"] ])


if __name__ == "__main__":
    w = yahoo_weather(city_id = sys.argv[1])
    print w.get_weather()

