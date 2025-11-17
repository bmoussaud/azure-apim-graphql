#!/bin/bash
# Quick test script for Microsoft Fabric GraphQL API

echo "Getting access token..."

TENANT_ID="de0dfa5c-3de9-4321-90aa-13727d0ca0b4"
#az login --tenant $TENANT_ID
FABRIC_ACCESS_TOKEN=$(az account get-access-token  --scope https://analysis.windows.net/powerbi/api/user_impersonation --query accessToken -o tsv)

if [ -z "$FABRIC_ACCESS_TOKEN" ]; then
    echo "Error: Could not get access token. Make sure you're logged in with 'az login'"
    exit 1
fi

echo "Access token acquired. ${FABRIC_ACCESS_TOKEN:0:20}... (truncated)"
echo "Testing endpoint..."
ENDPOINT="https://f8266fef6a6b42e7aed3e2c8d8b4ab75.zf8.graphql.fabric.microsoft.com/v1/workspaces/f8266fef-6a6b-42e7-aed3-e2c8d8b4ab75/graphqlapis/245e939b-f666-40db-8d53-be4996c1030b/graphql"
ENDPOINT="https://apim-tgebslojbs6y2.azure-api.net/fabric-graphql"
ENDPOINT="https://cb0442cc43ea4c819fea0bba9b62f870.zcb.graphql.fabric.microsoft.com/v1/workspaces/cb0442cc-43ea-4c81-9fea-0bba9b62f870/graphqlapis/64f58335-5d12-441d-b5e5-51778048a084/graphql"

# Test 1: Schema introspection query
SCHEMA_QUERY='query { __schema { queryType { name } types { name kind } } }'
echo "Testing schema introspection..."
curl -X POST "$ENDPOINT" \
  -H "Authorization: Bearer $FABRIC_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$SCHEMA_QUERY\"}" \
  -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n"

echo -e "\n---\n"

# Test 2: Valid query using available schema
LEGRAND_QUERY='query { factory_iot_datas(first: 10) { items { Timestamp BuildingID DeviceID Location MetricType Value Unit Status } hasNextPage endCursor } }'
echo "Testing legrand_iot_datas query..."
curl -X POST "$ENDPOINT" \
  -H "Authorization: Bearer $FABRIC_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$LEGRAND_QUERY\"}" \
  -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
  -v