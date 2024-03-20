#!/bin/bash

set -e

scripts/build-docker.sh
docker run -it --device /dev/kvm --privileged scanner-eval /scripts/run-eval.sh
