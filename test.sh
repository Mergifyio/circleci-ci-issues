#!/bin/bash

# This example uses envsubst to support variable substitution in the string parameter type.
# https://circleci.com/docs/orbs-best-practices/#accepting-parameters-as-strings-or-environment-variables

#TO=$(circleci env subst "${PARAM_TO}")
# If for any reason the TO variable is not set, default to "World"
#echo "Hello ${TO:-World}!"

set -x

export REPO_URL=https://github.com/Mergifyio/circleci-ci-issues
export FAKE_VALID_TOKEN=fake-valid-token
export TOKEN=FAKE_VALID_TOKEN
export CIRCLE_JOB=test
export CIRCLE_SHA1=948da8c01b17ac2164039f3150221d5cfcae7ecc
export FILES=zfixtures/junit_example.xml
export MERGIFY_API_SERVER=http://localhost:1080


if [[ $REPO_URL =~ ^https:\/\/github\.com\/([a-zA-Z0-9._-]+)\/([a-zA-Z0-9._-]+)$ ]]; then
  REPO_FULL_NAME=${BASH_REMATCH[1]}/${BASH_REMATCH[2]}
else
  echo "Invalid repository URL: $REPO_URL"
  exit 1
fi

# TODO: support multiple files
curl -X POST \
  -H "Authorization: bearer ${!TOKEN}" \
  -F name=${CIRCLE_JOB} \
  -F provider=circleci \
  -F head_sha=${CIRCLE_SHA1} \
  -F files=@${FILES} \
  -o result.json \
  ${MERGIFY_API_SERVER}/repos/${REPO_FULL_NAME}/ci_issues_upload \

echo "Display result"
cat result.json

GIGID=$(cat result.json | jq -r .gigid)
echo "::notice title=CI Issues report::CI_ISSUE_GIGID=$GIGID"

#            echo "CI_ISSUE_GIGID=$GIGID" >> "$GITHUB_OUTPUT"
