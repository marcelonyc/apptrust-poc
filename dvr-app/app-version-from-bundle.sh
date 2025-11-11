#!/bin/bash 

# BEFORE YOU RUN THIS SCRIPT, MAKE SURE YOU HAVE:
# export these variables:
# JF_TOKEN 
# PRIVATE_KEY (for evidence signing) must be rsa private key in PEM format, with newlines replaced by 
# JF_URL=apptrustswampupc.jfrog.io/
#
# Also, Create: Project, repos and application in Artifactory and AppTrust
# Add the AppTrust server in JFrog CLI with: jf config add AppTrustC --artifactory-url=https://apptrustswampupc.jfrog.io/artifactory --access-token=$JF_TOKEN
#

#
# CHANGE THIS TO BE YOUR OWN VALUES!!!
#
source ~/.env_apptrust
CREATE_RLM=false  # set to false to skip release bundle creation
JF_PROJECT="dvr"
APPLICATION_KEY="dvr-app"
JFROG_CLI_BUILD_NAME='dvr-build'
JFROG_CLI_BUILD_NUMBER=34
JFROG_CLI_BUILD_PROJECT=$JF_PROJECT
APP_VERSION="${JFROG_CLI_BUILD_NUMBER}.7"  # CHANGE THIS TO CREATE A NEW VERSION
DOCKER_REPO="dvr-docker-local-all-stages"
IMAGE_NAME="dvr-app"

#
# ^ MAKE THIS YOUR OWN VALUES ^
#

jf config use ${JF_CLI_INSTANCE_ID}

if [ $CREATE_RLM = true ]; then
  echo "📦 Creating release bundle for version $APP_VERSION ..."
  jf release-bundle-create --build-name dvr-build --build-number 34 dvr-app $APP_VERSION --project dvr
else
  echo "⚠️  Skipping release bundle creation"
fi


## APPTRUST STUFF
BASE="${JF_URL}apptrust/api/v1"
APP_KEY="dvr-rental" 
APP_VERSION="$APP_VERSION"

ACTUAL_BUILD_NAME=${JFROG_CLI_BUILD_NAME}
ACTUAL_BUILD_NUMBER=${JFROG_CLI_BUILD_NUMBER}
RLM_REPO="dvr-release-bundles-v2"

echo "🔧 Using actual build number from first job: $ACTUAL_BUILD_NUMBER"
RLM='{
                "name": "dvr-app",
                "version": "34.7",
                "repository_key": "'$RLM_REPO'"
            }'

APP_VERSION_PAYLOAD=$(jq -n \
  --arg appVersion "$APP_VERSION" \
  --arg rlmRepo "$RLM_REPO" \
  --arg rlm "$RLM" \
  --slurpfile payload app_payload_rlm.json \
  '.version = $appVersion 
  | .tag = ""
  | .sources.release_bundles += [ ($rlm | fromjson) ]')


echo "📋 Creating application version with payload:"
echo "$APP_VERSION_PAYLOAD" | jq . || echo "$APP_VERSION_PAYLOAD"

curl -sS -L -X POST \
    "https://${BASE}/applications/$APP_KEY/versions?async=false" \
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$APP_VERSION_PAYLOAD" \
    --fail-with-body



