#!/bin/bash

set -e

scripts/build-docker.sh
# sudo usermod -a -G kvm $USER
# docker run -idt --device /dev/kvm --privileged scanner-eval /scripts/run-eval.sh
docker run -it --privileged scanner-eval /scripts/run-eval.sh
