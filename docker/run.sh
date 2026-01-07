#!/bin/bash
set -e

VERSION=$1
OWN_DIR=`dirname "$0"`

RESULTS_FOLDER=${OWN_DIR}/../results/${VERSION}/results
WORKING_DIR=${OWN_DIR}/../results/${VERSION}/work-dir

mkdir -p $RESULTS_FOLDER
mkdir -p $WORKING_DIR

echo "Start:" $(date) > $RESULTS_FOLDER/date.txt

# Build image.
scripts/build-docker.sh
# Start container.
docker stop inspectre_container 2>&1 > /dev/null || echo ""
docker rm inspectre_container 2>&1 > /dev/null || echo ""
docker run -it --name inspectre_container -d -v $RESULTS_FOLDER:/results -v $WORKING_DIR:/work-dir --privileged inspectre  bash
# # Run eval in container.
docker exec -e LINUX_VERSION=$VERSION -it inspectre_container /scripts/run-gadget-scanning.sh

echo "End:" $(date) >> $RESULTS_FOLDER/date.txt
