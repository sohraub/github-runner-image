#!/bin/bash

# Get Org name and GitHub access token from environment variables supplied to container
ORGANIZATION=$ORGANIZATION
ACCESS_TOKEN=$ACCESS_TOKEN

# Create runner name with suffix made of random string
RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="dockerRunner-${RUNNER_SUFFIX}"
RUNNER_LABELS=$RUNNER_LABELS

# Request a runner registration token for your organization
REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" \
	    https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token \
	    | jq .token --raw-output)

# Configure the runner with your organization
cd /home/runner/actions-runner
if [[ $EPHMERAL = 'false' ]]; then
  ./config.sh --url https://github.com/${ORGANIZATION} --token ${REG_TOKEN} \
  --name ${RUNNER_NAME} --labels x64,linux,worker,${RUNNER_LABELS} --runnergroup Default --work _work
else
  ./config.sh --url https://github.com/${ORGANIZATION} --token ${REG_TOKEN} --ephemeral \
  --name ${RUNNER_NAME} --labels x64,linux,worker,${RUNNER_LABELS} --runnergroup Default --work _work
fi

./run.sh 
