#! /bin/sh

source ~/.env_apptrust

gh variable set JF_URL --body "$JF_URL"
gh secret set JF_TOKEN --body "$JF_TOKEN"
gh variable set JF_REGISTRY --body "$JF_REGISTRY"
gh secret set OIDC_PROVIDER_NAME --body "$OIDC_PROVIDER_NAME"
gh secret set PRIVATE_KEY --body "$PRIVATE_KEY"