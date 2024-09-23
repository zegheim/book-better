#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# This script will be run from inside terraform/, hence the ../

LAMBDA_DIR="../build_output/lambda"

if [ -d $LAMBDA_DIR ]
then
    rm -r $LAMBDA_DIR
fi

mkdir -p $LAMBDA_DIR
cp -r ../book_better $LAMBDA_DIR
cp -r ../lambda $LAMBDA_DIR