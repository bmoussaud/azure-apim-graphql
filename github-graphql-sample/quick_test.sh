#!/bin/bash
# Quick test script for Microsoft Fabric GraphQL API

echo "Getting access token..."
FABRIC_ACCESS_TOKEN=$(az account get-access-token --resource https://analysis.windows.net/powerbi/api --query accessToken -o tsv)

if [ -z "$FABRIC_ACCESS_TOKEN" ]; then
    echo "Error: Could not get access token. Make sure you're logged in with 'az login'"
    exit 1
fi

echo "Testing endpoint..."
ENDPOINT="https://f8266fef6a6b42e7aed3e2c8d8b4ab75.zf8.graphql.fabric.microsoft.com/v1/workspaces/f8266fef-6a6b-42e7-aed3-e2c8d8b4ab75/graphqlapis/245e939b-f666-40db-8d53-be4996c1030b/graphql"

curl -X POST "$ENDPOINT" \
  -H "Authorization: Bearer $FABRIC_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query": "query { __schema { queryType { name } } }"}' \
  -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
  -v