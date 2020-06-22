#!/usr/bin/env bash

# import_assessment.sh ASSESSMENT_FILE

# This script simplifies the process of importing an assessment JSON file
# into the GoPhish server running in the local Docker composition.

set -o errexit
set -o nounset
set -o pipefail

if [ $# -ne 1 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    echo "Usage: import_assessment.sh ASSESSMENT_FILE"
    exit 255
fi

# Source common variables and functions
SCRIPTS_DIR=$(readlink -f "$0" | xargs dirname)
# shellcheck source=gophish-tools/gophish_common.sh
source "$SCRIPTS_DIR/gophish_common.sh"

ASSESSMENT_FILE=$1
ASSESSMENT_FILE_BASE=$(basename "$ASSESSMENT_FILE")
ASSESSMENT_FILE_DIR=$(readlink -f "$ASSESSMENT_FILE" | xargs dirname)

# Disable errexit to allow error-handling within get_gophish_api_key
# and for the subsequent docker-compose call to gophish-import
set +o errexit

# Fetch GoPhish API key
API_KEY=$(get_gophish_api_key)

# Run gophish-import in the Docker composition
docker-compose -f "$GOPHISH_COMPOSITION" run --rm \
  --volume "$ASSESSMENT_FILE_DIR":/home/cisa gophish-tools \
  gophish-import "$ASSESSMENT_FILE_BASE" "$GOPHISH_URL" "$API_KEY"
import_rc="$?"
if [ "$import_rc" -eq 0 ]
then
  echo "Assessment successfully imported from $ASSESSMENT_FILE!"
  echo ""
else
  echo "ERROR: Assessment import from $ASSESSMENT_FILE failed!"
  exit $import_rc
fi
set -o errexit

# Schedule each campaign to be completed at the specified time
# via the "at" command
for campaign in $(jq '.campaigns | keys | .[]' "$ASSESSMENT_FILE")
do
  campaign_name=$(jq -r ".campaigns[$campaign].name" "$ASSESSMENT_FILE")
  end_date=$(jq -r ".campaigns[$campaign].complete_date" "$ASSESSMENT_FILE")

  end_date_in_at_format=$(date -d "$end_date" +"%Y%m%d%H%M.%S")

  # Disable errexit to allow error-handling of next command
  set +o errexit
  echo "$SCRIPTS_DIR/complete_campaign.sh $campaign_name" | \
    at -M -t "$end_date_in_at_format"
  schedule_rc="$?"
  if [ "$schedule_rc" -eq 0 ]
  then
    echo "Successfully scheduled campaign $campaign_name to complete at $end_date."
  else
    echo "ERROR: Failed to schedule campaign $campaign_name to complete at $end_date!"
    exit $schedule_rc
  fi
  set -o errexit
done
echo "All campaigns successfully scheduled for completion."
