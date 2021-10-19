#!/usr/bin/env bash

#============================
#   Li-PCA Setup Script
#============================
# This setup/management script simplifies the creation/management of campaigns
# in Gophish by orchestrating the flow of the capabilities derived from
# cisagov/gophish-tools project as well as other scripts within this project.
#
# The benefit provided is removal of the legacy approach where manual user
# interaction was required by the user to create template/import files and move
# them to the correct path locations through various steps. This also removes
# the need to remember various Docker run commands for various images/scripts
# and simplifies the flow of the Gophish campaign interaction process.
#
# The Constants below in ALL_CAPS follow this format: ${ENV_VAR:-default_value}
#
# This method provides flexibilty in deployments by allowing these values to
# easily be modified or customized for certain environments without the need
# for additional code changes. If this proves to not add value or increases
# complexity, it should be modified or removed.
#
# No environment variables or overrides are required to run this project as it
# was originally intended with the default values set. This is simply for customization
# if needed.
#
# If customization or modifications are needed, an example of how to use environment
# variable overrides is to define a new value to an environment variable matching
# the name of the respective value you would like to override. Using the example
# above ${ENV_VAR:-default_value}, it's possible to define ENV_VAR="new_value"
# in the target environment and "new_value" would be assigned instead of the initially
# defined "default_value". (Example: run export ENV_VAR="new_value")
#
#
# Documentation: https://github.com/cisagov/pca-runbooks/wiki/X:-Li-PCA-Infrastructure-Setup-(in-work)

# BASE PATHS
CISA_HOME="${CISA_HOME:-/home/cisa}"
PCA_GOPHISH_COMP_ROOT_PATH="${PCA_GOPHISH_COMP_ROOT_PATH:-/var/pca/pca-gophish-composition}"
GOPHISH_UTILS_ROOT_PATH="${GOPHISH_UTILS_ROOT_PATH:-$PCA_GOPHISH_COMP_ROOT_PATH/gophish-tools}"
COMPLETE_CAMPAIGN_PATH="${COMPLETE_CAMPAIGN_PATH:-$GOPHISH_UTILS_ROOT_PATH/complete_campaign.sh}"
IMPORT_ASSESSMENT_PATH="${IMPORT_ASSESSMENT_PATH:-$GOPHISH_UTILS_ROOT_PATH/import_assessment.sh}"
TEST_ASSESSMENT_PATH="${TEST_ASSESSMENT_PATH:-$GOPHISH_UTILS_ROOT_PATH/test_assessment.sh}"
EXPORT_ASSESSMENT_PATH="${EXPORT_ASSESSMENT_PATH:-$GOPHISH_UTILS_ROOT_PATH/export_assessment.sh}"

# IMAGE NAMES
TOOLS_IMAGE_NAME="${TOOLS_IMAGE_NAME:-cisagov/gophish-tools}"

# ALIASES
TEMPLATE_ALIAS="${TEMPLATE_ALIAS:-pca-wizard-templates}"
WIZARD_ALIAS="${WIZARD_ALIAS:-pca-wizard}"

# LOCAL VOLUME MAPPING PATHS
EFS_SHARE="${ENV_SHARE:-/share}"
PCA_OPS_PATH="${PCA_OPS_PATH:-$EFS_SHARE/PCA}"
PCA_DEV_PATH="${PCA_DEV_PATH:-$EFS_SHARE/private}"

# OPS PATH SETUP
ASSESSMENT_PATH="${PCA_ASSESSMENT_PATH:-$PCA_DEV_PATH/assessments}"
LOG_PATH="${PCA_LOG_PATH:-$PCA_DEV_PATH/logs}"
LOG_FILE="${PCA_LOG_FILE:-$LOG_PATH/log-$(date +'%m-%d-%Y_%H-%M-%S')}"

# DEV PATH SETUP
TEMPLATE_PATH="${PCA_TEMPLATE_PATH:-$PCA_OPS_PATH/templates}"
EXPORT_PATH="${PCA_EXPORT_PATH:-$PCA_OPS_PATH/exports}"
TEMPLATE_INGESTION_PATH="${TEMPLATE_INGESTION_PATH:-$ASSESSMENT_PATH}"

# ASSESSMENT PLACEHOLDERS
ASSESSMENT_NAME="${PCA_ASSESSMENT_NAME:-assessment-$(date +'%m-%d-%Y_%H-%M-%S')}"
ASSESSMENT_ID=""

# TEMPLATE NAMES
TEMPLATE_EMAIL_FILENAME="${TEMPLATE_EMAIL_FILENAME:-template_email.json}"
TEMPLATE_TARGETS_FILENAME="${TEMPLATE_TARGETS_FILENAME:-template_targets.csv}"

#=============================
#          UTILS
#=============================

output_dir_setup() {
  # Setup /share subdirs and permissions for mapped volume data
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
  echo "Log file created at: $LOG_PATH"
}

handle_error() {
  # Error output
  # TODO: enhance output and error handling)
  echo "Error during LiPCA Setup. Please see error output or logs at $LOG_PATH and try again."
}

#=============================
#     TEMPLATE CREATION
#=============================

create_target_template() {
  # Runs pca-wizard-templates tool in gophish-tools container and outputs
  # a pre-formatted csv file named "template_targets.csv" in the specified
  # directory and open vim to edit the template as needed for modification.
  sudo docker run -it --rm --workdir="$CISA_HOME" -v "$TEMPLATE_PATH":"$CISA_HOME":Z "$TOOLS_IMAGE_NAME" "$TEMPLATE_ALIAS" -t && sudo vi "$TEMPLATE_TARGETS_FILENAME"
}

create_email_template() {
  # Runs pca-wizard-templates tool in gophish-tools container and outputs
  # a pre-formatted json file named "template_email.json" file in the specified
  # directory and open vim to edit the template as needed for modification.
  sudo docker run -it --rm --workdir="$CISA_HOME" -v "$TEMPLATE_PATH":"$CISA_HOME":Z "$TOOLS_IMAGE_NAME" "$TEMPLATE_ALIAS" -e && sudo vi "$TEMPLATE_EMAIL_FILENAME"
}

email_template_prompt() {
  # Prompt user and ask if template generation is needed.
  while true; do
    read -rp "Do you need an email template file generated? (yes/no) " yn
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
    read -rp "Do you need a targets template file generated? (yes/no) " yn
    case $yn in
      [Yy]*)
        create_target_template
        break
        ;;
      [Nn]*)
        echo "Skipping targets template creation and proceeding with setup."
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
  # Runs the pca-wizard tool to setup a new campaign
  read -rp 'Enter assessment id/name for new assessment: ' id
  read -rp 'Enter level of the new assessment (1-6): ' level

  # TODO: Determine if we want to keep mix of underscores and hypens in level naming.
  ASSESSMENT_NAME="$id"_level-"$level"
  FULL_ASSESSMENT_PATH="$ASSESSMENT_PATH/$ASSESSMENT_NAME"

  # Copy templates for injestion
  echo "Copying template files named template_* for use in setup process."
  sudo cp /share/PCA/templates/template_* "$TEMPLATE_INGESTION_PATH"
  echo "Templates copied to: $TEMPLATE_INGESTION_PATH"

  # Run using docker gophish-tools image pca-wizard
  sudo docker run -it --rm --workdir="$CISA_HOME" -v "$ASSESSMENT_PATH":"$CISA_HOME":Z "$TOOLS_IMAGE_NAME" "$WIZARD_ALIAS" "$ASSESSMENT_NAME"
  echo "Saved Assessment: $FULL_ASSESSMENT_PATH"
}

import_assessment() {
  # Runs the import-assessment.sh script to import the generated assessment.json
  # data in the lipca-temp dir (generated from create_assessment)
  "$IMPORT_ASSESSMENT_PATH" "$FULL_ASSESSMENT_PATH".json
}

export_assessment() {
  # Runs the export-assessment.sh script to export the generated assessment
  # data in the lipca-temp dir (generated from create_assessment)
  "$EXPORT_ASSESSMENT_PATH" "$ASSESSMENT_ID"
}

test_assessment() {
  # Run test_assessment.sh script against the newly imported assessment
  "$TEST_ASSESSMENT_PATH" "$ASSESSMENT_ID"
}

export_by_id_prompt() {
  # Prompts the user for the target ASSESSMENT_ID to be exported.
  while true; do
    read -rp "Would you like to export data from an existing completed assessment? (yes/no) " yn
    case $yn in
      [Yy]*)
        read -rp "Enter the ASSESSMENT_ID to export data: " id
        ASSESSMENT_ID="$id"
        export_assessment && exit
        ;;
      [Nn]*) echo "Skipping assessment export.." && break ;;
      *) echo "Please specify the ASSESSMENT_ID." ;;
    esac
  done
}

export_prompt() {
  # Prompts the user to ask if the target action is to export data.
  while true; do
    read -rp "Do you want to export data from an existing completed assessment? (yes/no) " yn
    case $yn in
      [Yy]*)
        export_assessment
        break
        ;;
      [Nn]*) echo "Skipping assessment tests." && break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

edit_email_temp_prompt() {
  while true; do
    read -rp "Do you want to edit the created email template? (yes/no) " yn
    case $yn in
      [Yy]*)
        sudo vi "$TEMPLATE_PATH/$TEMPLATE_EMAIL_FILENAME"
        break
        ;;
      [Nn]*) echo "Skipping template editing." && break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

edit_targets_temp_prompt() {
  while true; do
    read -rp "Do you want to edit the created targets template? (yes/no) " yn
    case $yn in
      [Yy]*)
        sudo vi "$TEMPLATE_PATH/$TEMPLATE_TARGETS_FILENAME"
        break
        ;;
      [Nn]*) echo "Skipping template editing." && break ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

test_by_id_prompt() {
  # Prompts the user for assessment id to test.
  while true; do
    read -rp "Do you need to test an existing assessment? (yes/no) " yn
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
    read -rp "Do you want to test the assessment? (yes/no) " yn
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
  $COMPLETE_CAMPAIGN_PATH "$CAMPAIGN_ID"
}

complete_campaign_prompt() {
  # Prompts the user to ask to complete campaign for cleanup.
  while true; do
    read -rp "Do you need to complete a previous campaign? (yes/no) " yn
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
    read -rp "Do you want to manage an existing campaign or assessment? (yes/no)" yn
    case $yn in
      [Yy]*)
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
  logging_setup

  echo "Beginning Li-PCA Setup Process."

  # Export/Complete Prompt
  # TODO: Determine if we want to force complete campaigns and uncomment.

  # Export_by_id_prompt && complete_campaign_prompt
  export_by_id_prompt

  # Template Prompt
  target_template_prompt && email_template_prompt

  # Campaign Setup and Import
  create_assessment && import_assessment

  # Testing Prompt
  # TODO: Determine if we want to prompt to test campaign and uncomment.
  # test_post_prompt

  echo "Li-PCA Setup Process Complete!!"
} || {
  # Error Handling
  handle_error
}
