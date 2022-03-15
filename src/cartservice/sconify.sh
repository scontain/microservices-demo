#!/bin/bash

CARTSERVICE_IMAGE="registry.scontain.com:5050/sconecuratedimages/cartservice:alpine"

echo "cartservice is written in C#, which is not yet support by sconify."
echo "Therefore we use a pre-built image with cartservice on SCONE:"
echo "  ""$CARTSERVICE_IMAGE"

