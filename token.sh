#!/usr/bin/env bash

if [ -z "$STREAMINGFAST_KEY" ]; then
    echo "Error: STREAMINGFAST_KEY is not set."
    exit 1
fi

export SUBSTREAMS_API_TOKEN=$(curl https://auth.streamingfast.io/v1/auth/issue -s --data-binary '{"api_key":"'$STREAMINGFAST_KEY'"}' | jq -r .token)
echo "Token set on in SUBSTREAMS_API_TOKEN"
