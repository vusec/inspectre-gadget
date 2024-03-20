#!/bin/bash

set -e

scripts/build-docker.sh
docker run -it  -v $(pwd)/results:/results --device /dev/kvm --privileged scanner-eval  /scripts/run-eval.sh
