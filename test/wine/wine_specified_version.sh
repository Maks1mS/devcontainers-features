#!/bin/bash
set -e

source dev-container-features-test-lib

check "wine version is same" [[ "$(wine --version | tr -d -c 0-9.)" == *"8.5"* ]]
check 

reportResults