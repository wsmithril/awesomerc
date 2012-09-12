#! /bin/bash

trap "echo TRAPED" INT

exec sleep 100

