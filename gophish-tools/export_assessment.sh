#!/usr/bin/env bash

# export_assessment.sh ASSESSMENT_ID

# This script simplifies the process of exporting assessment data from the
# GoPhish server running in the local Docker composition to a JSON file.

set -o errexit
set -o nounset
set -o pipefail

if [ $# -ne 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: export_assessment.sh ASSESSMENT_ID"
  exit 255
fi

# Source common variables and functions
SCRIPTS_DIR=$(readlink -f "$0" | xargs dirname)
# shellcheck source=gophish-tools/gophish_common.sh
source "$SCRIPTS_DIR/gophish_common.sh"

ASSESSMENT_ID=$1

GOPHISH_WRITABLE_DIR="/var/pca/pca-gophish-composition/data"

# Disable errexit to allow error-handling within get_gophish_api_key
# and for the subsequent docker compose call to gophish-export
set +o errexit

# Fetch GoPhish API key
API_KEY=$(get_gophish_api_key)

# Run gophish-export in the Docker composition
docker compose -f "$GOPHISH_COMPOSITION" run --rm \
  --volume "$GOPHISH_WRITABLE_DIR":/home/cisa \
  gophish-tools gophish-export "$ASSESSMENT_ID" "$GOPHISH_URL" "$API_KEY"
export_rc="$?"
if [ "$export_rc" -eq 0 ]; then
  echo "Assessment data successfully exported to: $GOPHISH_WRITABLE_DIR/data_$ASSESSMENT_ID.json"
else
  echo "ERROR: Failed to export GoPhish assessment $ASSESSMENT_ID data!"
  exit $export_rc
fi
