#!/usr/bin/env bash
#
# Li-PCA Script Script
#
# This script simplifies the process of assessment management in GoPhish and
# is meant to be ran from the COOL host's pca-gophish-composition/gophish-tools.
# It will execute commands in various docker containers and move configs and output
# as needed. Logs and output files will be stored in the directory
# "/home/vnc/lipca-temp" for reference.
#
# The script will ask a series of questions that you will need to complete along
# the way.
#
# **For multiple outgoing mail errors or "Connections Refused" output issues,
# try restarting the postfix container by running "docker-compose restart
# postfix". Wait for the container to start and then try again.
#
# TODO: Consider refacoring/rewriting as a more generic python cli tool
# (possibly the click python library?). We would get more flexibility with
# passing args/flags to thelipca-taolthis a  lipca-tool

# Override default values with ENV vars in container if needed.


# Base Paths
CISA_HOME=/home/cisa
PCA_GOPHISH_COMP_ROOT_PATH=/var/pca/pca-gophish-composition
GOPHISH_UTILS_ROOT_PATH="$PCA_GOPHISH_COMP_ROOT_PATH/gophish-tools"
COMPLETE_CAMPAIGN_PATH="$GOPHISH_UTILS_ROOT_PATH/complete_campaign.sh"
IMPORT_ASSESSMENT_PATH="$GOPHISH_UTILS_ROOT_PATH/import_assessment.sh"
TEST_ASSESSMENT_PATH="$GOPHISH_UTILS_ROOT_PATH/test_assessment.sh"
EXPORT_ASSESSMENT_PATH="$GOPHISH_UTILS_ROOT_PATH/export_assessment.sh"

# Image Names
TOOLS_IMAGE_NAME=cisagov/gophish-tools:0.0.6-rc.11

# Aliases
TEMPLATE_ALIAS=pca-wizard-templates
WIZARD_ALIAS=pca-wizard

# Local volume for data from containers
EFS_SHARE="${ENV_SHARE:-/share}"
PCA_OPS_PATH="${PCA_OPS_PATH:-$EFS_SHARE/PCA}"
PCA_DEV_PATH="${PCA_DEV_PATH:-$EFS_SHARE/private}"

# OPS Path Setup
ASSESSMENT_PATH="${PCA_ASSESSMENT_PATH:-$PCA_DEV_PATH/assessments}"
LOG_PATH="${PCA_LOG_PATH:-$PCA_DEV_PATH/logs}"
LOG_FILE="${PCA_LOG_FILE:-$LOG_PATH/log-$(date +'%m-%d-%Y_%H-%M-%S')}"

# DEV Path Setup
TEMPLATE_PATH="${PCA_TEMPLATE_PATH:-$PCA_OPS_PATH/templates}"
EXPORT_PATH="${PCA_EXPORT_PATH:-$PCA_OPS_PATH/exports}"

# Assessment Placeholders
ASSESSMENT_NAME="${PCA_ASSESSMENT_NAME:-assessment-$(date +'%m-%d-%Y_%H-%M-%S')}"
ASSESSMENT_ID=""


#=============================
#          UTILS
#=============================

output_dir_setup() {
  # Setup /share subdir and permissions
  # TODO: Determine ownership needs and setup here. Is sudo required?
  sudo mkdir -p "$PCA_DEV_PATH"
  sudo mkdir -p "$PCA_OPS_PATH"
  sudo mkdir -p "$TEMPLATE_PATH"
  sudo mkdir -p "$ASSESSMENT_PATH"
  sudo mkdir -p "$EXPORT_PATH"
  sudo mkdir -p "$LOG_PATH"
  sudo chmod --recursive 775 "$EFS_SHARE"
  sudo chown -R vnc:gophish "$EFS_SHARE"
}

logging_setup() {
  exec &> >(tee -a "$LOG_FILE")
  echo "Logging destination: %s" "$LOG_PATH"
}

handle_error() {
  # Error output (TODO: enhance output and error handling)
  echo "Error during LiPCA Setup. Please see error output or logs at $LOG_PATH and try again."
}


#=============================
#     TEMPLATE CREATION
#=============================

create_target_template() {
  # Runs pca-wizard-templates tool in gophish-tools container and output
  # a pre-formatted csv file named "template_targets.csv" in the lipca-temp directory.
  sudo docker run -it --workdir="$CISA_HOME" -v "$TEMPLATE_PATH":"$CISA_HOME":Z "$TOOLS_IMAGE_NAME" "$TEMPLATE_ALIAS" -t
}

create_email_template() {
  # Runs pca-wizard-templates tool in gophish-tools container and outputs
  # a pre-formatted json file named "template_email.json" file in the lipca-temp directory.
  sudo docker run -it --workdir="$CISA_HOME" -v "$TEMPLATE_PATH":"$CISA_HOME":Z "$TOOLS_IMAGE_NAME" "$TEMPLATE_ALIAS" -e
}

email_template_prompt() {
  # Prompt user and ask if template generation is needed.
  while true; do
    read -rp "Do you need an email template file generated? (y/n) " yn
    case $yn in
      [Yy]*)
        create_email_template
        break
        ;;
      [Nn]*) echo "Skipping email template creation and proceeding with setup." && break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

target_template_prompt() {
  # Prompt user and ask if template generation is needed.
  while true; do
    # Input R
    read -rp "Do you need an email targets file generated? (y/n) " yn
    case $yn in
      [Yy]*)
        create_target_template
        break
        ;;
      [Nn]*)
        echo "Skipping target Template creation and proceeding with setup."
        break
        ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}


#=============================
#     ASSESSMENT TOOLS
#=============================
create_assessment() {
  #  Runs the pca-wizard tool to setup a new campaign generate and saves the
  #  output json to the lipca-temp directory for importing

  # Make dir for assessment output

  read -rp 'Enter assessment id/name for new assessment: ' id
  read -rp 'Enter level of the new assessment (1-6): ' level

  # TODO: Determine if we want to mix underscores and hypens in level naming.
  ASSESSMENT_NAME="$id"_level-"$level"
  # ASSESSMENT_NAME="$id"

  # TODO: Determine if we want to specify date or automate name
  # ASSESSMENT_NAME="assessment-$(date +'%m-%d-%Y_%H-%M-%S')"

  FULL_ASSESSMENT_PATH="$ASSESSMENT_PATH/$ASSESSMENT_NAME"

  # Run using docker gophish-tools image pca-wizard
  sudo docker run -it --workdir="$CISA_HOME" -v "$ASSESSMENT_PATH":"$CISA_HOME":Z "$TOOLS_IMAGE_NAME" "$WIZARD_ALIAS" "$ASSESSMENT_NAME"
  echo "Saved Assessment at: $FULL_ASSESSMENT_PATH"
}

import_assessment() {
  # Runs the import-assessment.sh script to import the generated assessment.json
  # data in the lipca-temp dir (generated from create_assessment)
  "$IMPORT_ASSESSMENT_PATH" "$FULL_ASSESSMENT_PATH".json
  # cd /var/pca/pca-gophish-composition/gophish-tools && ./import_assessment.sh "$FULL_ASSESSMENT_PATH".json
}

export_assessment() {
  # Runs the export-assessment.sh script to export the generated assessment
  # data in the lipca-temp dir (generated from create_assessment)
  "$EXPORT_ASSESSMENT_PATH" "$ASSESSMENT_ID"
}


test_assessment() {
  ## Run test_assessment.sh script against the newly imported assessment
  "$TEST_ASSESSMENT_PATH" "$ASSESSMENT_ID"
}


export_by_id_prompt() {
  # Prompts the user to asking if assessment export is needed. Requires
  while true; do
    read -rp "Would you like to export data from an existing completed assessment? (y/n) " yn
    case $yn in
      [Yy]*)
        read -rp "Enter the ASSESSMENT_ID to export data: " id
        ASSESSMENT_ID="$id"
        export_assessment && break ;;
      [Nn]*) echo "Skipping assessment export.." && break ;;
      *) echo "Please specify the ASSESSMENT_ID." ;;
    esac
  done
}


export_prompt() {
  # Prompts the user to ask if assessment data export is required.
  while true; do
    read -rp "Do you want to export data from an existing completed assessment? (y/n) " yn
    case $yn in
      [Yy]*)
        # test_assessment
        #export_by_id_prompt()
        export_assessment
        break
        ;;
      [Nn]*) echo "Skipping assessment tests." && break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

test_by_id_prompt() {
  # Prompts the user to test campaign by passing an id with passing
  while true; do
    read -rp "Do you need to test an existing assessment? (y/n) " yn
    case $yn in
      [Yy]*) read -rp "Enter the ASSESSMENT_ID to test: " id ASSESSMENT_ID="$id" && test_assessment && break ;;
      [Nn]*) echo "Skipping assessment testing.." && break ;;
      *) echo "Please specify the ASSESSMENT_ID." ;;
    esac
  done
}

test_post_prompt() {
  # Prompts the user to ask if the new assessment test should be tested.
  while true; do
    read -rp "Do you want to test the assessment? (y/n) " yn
    case $yn in
      [Yy]*)
        test_assessment
        break
        ;;
      [Nn]*) echo "Skipping assessment tests." && break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}


#=============================
#     COMPLETE CAMPAIGN
#=============================
complete_campaign() {
  # Run locally pca-gophish-composition/gophish-tools
  ./$COMPLETE_CAMPAIGN_PATH "$CAMPAIGN_ID"
}

complete_campaign_prompt() {
  # Prompts the user to ask to complete campaign for cleanup.
  while true; do
    read -rp "Do you need to complete a previous campaign? (y/n) " yn
    case $yn in
      [Yy]*) read -rp "Enter Campaign ID: " CAMPAIGN_ID CAMPAIGN_ID="$CAMPAIGN_ID" && complete_campaign && break ;;
      [Nn]*) echo "Skipping campaign completion and proceeding with setup. " && break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

create_or_manage_prompt() {
  # Prompts the user for setup or manage actions
  while true; do
    read -rp "Do you want to manage an existing campaign or assessment? (y/n)" yn
    case $yn in
      [Yy]*)
        # Campaign Cleanup Prompt
        complete_campaign_prompt
        test_assessment
        test_prompt
        break
        ;;
      [Nn]*) echo "Proceeding to setup tasks." && break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

#===========================
#       Entrypoint
#===========================
{
  output_dir_setup

  # Logging Setup
  logging_setup
  # exec >"$LOG_FILE" 2>&1

  echo "Beginning Li_PCA Setup Process."

  # Export/Complete Prompt
  # TODO: Determine if we want to force complete campaigns and export
  #export_by_id_prompt && complete_campaign_prompt
  export_by_id_prompt

  # Template Prompt
  target_template_prompt && email_template_prompt

  # Campaign Setup and Import
  create_assessment && import_assessment

  # Testing Prompt
  test_post_prompt

  echo "Li_PCA Setup Process Complete!!"
  } || {
  # Error Handling
  handle_error
}
