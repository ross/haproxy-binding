#!/bin/bash

set -e

docker build -t haproxy-reloads . 

docker run --rm --cap-add=NET_ADMIN --name haproxy-reloads haproxy-reloads
