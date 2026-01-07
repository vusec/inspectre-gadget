#!/bin/bash

set -e

mkdir -p inspectre

echo " • Syncing analyzer"
rsync -ap ../analyzer ./inspectre/

echo " • Syncing reasoner"
rsync -ap ../reasoner ./inspectre/

echo " • Syncing rest"
rsync -ap ../requirements.txt ./inspectre/
rsync -ap ../inspectre ./inspectre/

echo " • Building container"
docker build . --network=host --tag inspectre
