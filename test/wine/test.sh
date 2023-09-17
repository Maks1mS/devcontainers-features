a#!/bin/bash
set -e

source dev-container-features-test-lib

check "wine exists" wine --version
check 

reportResults