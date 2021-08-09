#!/usr/bin/env bash

# complete_campaign.sh CAMPAIGN_ID

# This script simplifies the process of completing a campaign on the
# GoPhish server running in the local Docker composition.

set -o errexit
set -o nounset
set -o pipefail

if [ $# -ne 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: complete_campaign.sh CAMPAIGN_ID"
  exit 255
fi

# Source common variables and functions
SCRIPTS_DIR=$(readlink -f "$0" | xargs dirname)
# shellcheck source=gophish-tools/gophish_common.sh
source "$SCRIPTS_DIR/gophish_common.sh"

CAMPAIGN_ID=$1

# Disable errexit to allow error-handling within get_gophish_api_key
# and for the subsequent docker-compose call to gophish-complete
set +o errexit

# Fetch GoPhish API key
API_KEY=$(get_gophish_api_key)

# Run gophish-complete in the Docker composition
docker-compose -f "$GOPHISH_COMPOSITION" run --rm \
  gophish-tools gophish-complete "--campaign=$CAMPAIGN_ID" \
  "$GOPHISH_URL" "$API_KEY"
complete_rc="$?"
if [ "$complete_rc" -eq 0 ]; then
  echo "GoPhish campaign $CAMPAIGN_ID successfully completed!"
else
  echo "ERROR: Failed to complete GoPhish campaign $CAMPAIGN_ID!"
  exit $complete_rc
fi
