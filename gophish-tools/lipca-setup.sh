#!/usr/bin/env bash
# Live-PCA Script

TEMP_DIR_NAME=lipca-temp
FULL_TEMP_PATH=$('pwd')/$TEMP_DIR_NAME
LOG_FILE="$FULL_TEMP_PATH/log-`date +'%m-%d-%Y_%H-%M-%S'`"
SERVER_API_KEY=some-key
GOPHISH_HOST=localhost
PCA_GOPHISH_HELPER_DIR=/var/pca/pca-gophish-composition/gophish-tools


######################
# CREATE_ASSESSMENT  #
######################

create_assessment () {
  WIZARD_OUTPUT_PATH=/var/cisagov/gophish-tools/assessment/builder.py
  ASSESSMENT_NAME="assessment-`date +'%m-%d-%Y_%H-%M-%S'`"
  FULL_ASSESSMENT_PATH=$TEMP_FULL_PATH/$ASSESSMENT_NAME

  # Run using docker gophish-tools image
  sudo docker run -it -v $('pwd')/$TEMP_DIR_NAME:/home/cisa cisagov/gophish-tools pca-wizard $ASSESSMENT_NAME
  echo "Saved Assessment at: $TEMP_FULL_PATH/$ASSESSMENT_NAME"
}


#####################
# IMPORT ASSESSMENT #
#####################

import_assessment () {
  # Run locally pca-gophish-composition/gophish-tools 
  cd $PCA_GOPHISH_HELPER_DIR && ./import_assessment.sh $FULL_ASSESSMENT_PATH

  # Run using docker gophish-tools image  TODO: Determine if needed
  # IMPORT_SCRIPT_DOCKER_PATH=/app/pca-gophish-composition/gophish-tools/import_assessment.sh
  # docker run -it -v $('pwd')/$TEMP_DIR_NAME:/home/cisa cisagov/gophish-tools gophish-import $ASSESSMENT_NAME.json $SERVER_API_KEY $GOPHISH_HOST
}


#####################
# COMPLETE CAMPAIGN #
#####################

complete_campaign () {
  # Run locally pca-gophish-composition/gophish-tools 
  cd $PCA_GOPHISH_HELPER_DIR && ./complete_campaign.sh $CAMPAIGN_ID

  # Run using docker gophish-tools image  TODO: Determine if needed
  # COMPLETE_SCRIPT_DOCKER_PATH=/app/pca-gophish-composition/gophish-tools/complete_campaign.sh
  # docker run -it gophish-tools bash -c "$COMPLETE_SCRIPT_DOCKER_PATH; bash"
}


###########
# HELPERS #
###########

logging_setup () {
  # Logging (Error redirecting running pca-wizard in container)
  # exec &> >(tee -a "$LOG_FILE")
  echo "Logging destination: $LOG_FILE"
}

handle_error () {
  # Error output (TODO: enhance output and error handling)
  echo "Error during LiPCA Setup. Please see error output and try again."
}


#########
# ENTRY #
#########

{
  echo "Beginning Li_PCA Setup"
  logging_setup

  # Create local temp dir to map to docker volume
  mkdir $TEMP_DIR_NAME
  echo "Created temp dir: $TEMP_DIR_NAME"

  # Chain main logic for streamlining process
  create_assessment && import_assessment

  echo "Li_PCA Setup Complete."
} || {
  handle_error
}

