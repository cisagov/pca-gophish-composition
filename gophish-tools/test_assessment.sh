#!/usr/bin/env bash

# test_assessment.sh ASSESSMENT_ID

# This script simplifies the process of sending test emails for an
# assessment in the GoPhish server running in the local Docker composition.

set -o errexit
set -o nounset
set -o pipefail

if [ $# -ne 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
  echo "Usage: test_assessment.sh ASSESSMENT_ID"
  exit 255
fi

# Source common variables and functions
SCRIPTS_DIR=$(readlink -f "$0" | xargs dirname)
# shellcheck source=gophish-tools/gophish_common.sh
source "$SCRIPTS_DIR/gophish_common.sh"

ASSESSMENT_ID=$1

# Disable errexit to allow error-handling within get_gophish_api_key
# and for the subsequent docker-compose call to gophish-test
set +o errexit

# Fetch GoPhish API key
API_KEY=$(get_gophish_api_key)

# Run gophish-test in the Docker composition
docker-compose -f "$GOPHISH_COMPOSITION" run --rm \
  gophish-tools gophish-test "$ASSESSMENT_ID" "$GOPHISH_URL" "$API_KEY"
test_rc="$?"
if [ "$test_rc" -eq 0 ]
then
  echo "Assessment $ASSESSMENT_ID test succeeded!"
else
  echo "ERROR: Assessment $ASSESSMENT_ID test failed!"
  exit $test_rc
fi
