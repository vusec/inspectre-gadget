#!/bin/bash
set -e

date > start.txt

# Build image.
scripts/build-docker.sh
# Start container.
mkdir -p results
docker stop inspectre_container || echo ""
docker rm inspectre_container || echo ""
docker run -it --name inspectre_container -d -v $(pwd)/results:/results --privileged scanner-eval  bash
# Run eval in container.
docker exec -it inspectre_container /scripts/run-eval.sh

date > end.txt
