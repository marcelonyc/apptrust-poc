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
JF_PROJECT="dvr"
APPLICATION_KEY="dvr-app"
VERSION="1.0.3"  # CHANGE THIS TO CREATE A NEW VERSION
JFROG_CLI_BUILD_NAME='dvr-build'
JFROG_CLI_BUILD_NUMBER=$VERSION
JFROG_CLI_BUILD_PROJECT=$JF_PROJECT
DOCKER_REPO="dvr-docker-local-all-stages"
IMAGE_NAME="dvr-app"
#
# ^ MAKE THIS YOUR OWN VALUES ^
#


jf config use ${JF_CLI_INSTANCE_ID}
docker build -t ${IMAGE_NAME}:${VERSION} .
docker login $JF_URL
jf docker tag ${IMAGE_NAME}:${VERSION} ${JF_URL}${DOCKER_REPO}/${IMAGE_NAME}:${VERSION}
jf rt docker-push --project ${JFROG_CLI_BUILD_PROJECT} \
 --build-name ${JFROG_CLI_BUILD_NAME} --build-number ${JFROG_CLI_BUILD_NUMBER} \
   ${JF_URL}${DOCKER_REPO}/${IMAGE_NAME}:${VERSION}  ${DOCKER_REPO}
# jf rt docker-push ${IMAGE_NAME}:${VERSION} ${DOCKER_REPO}
jf rt bp --project ${JFROG_CLI_BUILD_PROJECT} \
 ${JFROG_CLI_BUILD_NAME} ${JFROG_CLI_BUILD_NUMBER}


# EVIDENCE STUFF
# Create signing evidence JSON file
SIGNING_ACTOR="marcelo"
SIGNING_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "{
\"actor\": \"${SIGNING_ACTOR}\",
\"date\": \"${SIGNING_DATE}\",
\"is_approved\": true
}" > sign.json

# Attach evidence using JFrog CLI
jf evd create \
--package-name ${IMAGE_NAME} \
--package-version "${VERSION}" \
--package-repo-name ${DOCKER_REPO} \
--predicate ./in-toto-test.json \
--predicate-type https://in-toto.io/attestation/test-result/v0.1 \
--key "${PRIVATE_KEY}" \
--key-alias "evd" 

jf evd create \
--build-name ${JFROG_CLI_BUILD_NAME} \
--build-number "${JFROG_CLI_BUILD_NUMBER}" \
--project ${JFROG_CLI_BUILD_PROJECT} \
--predicate ./sign.json \
--predicate-type https://jfrog.com/evidence/signature/v1 \
--key "${PRIVATE_KEY}" \
--key-alias "evd" 

if [ $? -ne 0 ]; then
  echo -e "🚨 ERROR: Failed to create build evidence 🚨"
  exit 1
fi

## APPTRUST STUFF
BASE="${JF_URL}apptrust/api/v1"
APP_KEY="dvr-rental" 
APP_VERSION="$VERSION"

ACTUAL_BUILD_NAME=${JFROG_CLI_BUILD_NAME}
ACTUAL_BUILD_NUMBER=${JFROG_CLI_BUILD_NUMBER}

echo "🔧 Using actual build number from first job: $ACTUAL_BUILD_NUMBER"
APP_VERSION_PAYLOAD='{"version":"'$APP_VERSION'","tag":"'$APP_TAG'","sources":{"builds":[{"name":"'$ACTUAL_BUILD_NAME'","number":"'$ACTUAL_BUILD_NUMBER'","repository_key":"'${JF_PROJECT}'-build-info","include_dependencies":false}]}}'

echo "📋 Creating application version with payload:"
echo "$APP_VERSION_PAYLOAD" | jq . || echo "$APP_VERSION_PAYLOAD"

curl -sS -L -X POST \
    "https://${BASE}/applications/$APP_KEY/versions?async=false" \
    -H "Authorization: Bearer $JF_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$APP_VERSION_PAYLOAD" \
    --fail-with-body



