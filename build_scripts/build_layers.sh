#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# This script will be run from inside terraform/, hence the ../

LAYERS_DIR="../build_output/layers"
REQUIREMENTS_FILE="../build_output/requirements.txt"

if [ -d $LAYERS_DIR ]
then
    rm -r $LAYERS_DIR
fi

mkdir -p "$LAYERS_DIR"
poetry export --output="$REQUIREMENTS_FILE"
pip install --quiet -r "$REQUIREMENTS_FILE" -t "$LAYERS_DIR/python/lib/python3.12/site-packages/"