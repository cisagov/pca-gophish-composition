# shellcheck shell=bash

# This file contains variables and functions used by the other scripts
# in this directory.

GOPHISH_COMPOSITION="/var/pca/pca-gophish-composition/docker-compose.yml"

# shellcheck disable=SC2034
# GOPHISH_URL is unused in this file, but it is used by other
# scripts that source this file
GOPHISH_URL="https://gophish:3333"

function get_gophish_api_key {
  # Fetch GoPhish API key
  API_KEY=$(docker-compose -f "$GOPHISH_COMPOSITION" exec -T gophish get-api-key)
  api_key_rc="$?"
  if [ "$api_key_rc" -ne 0 ]
  then
    echo "ERROR: Failed to obtain GoPhish API key from Docker composition."
    echo "Exiting without importing."
    exit 1
  fi

  echo "$API_KEY"
}
