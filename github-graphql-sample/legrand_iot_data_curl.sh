#!/bin/bash

# Legrand IoT Data GraphQL Query Script
# This script demonstrates how to query legrand_iot_data using curl

# Configuration - Update these variables with your actual values
GRAPHQL_ENDPOINT="https://f8266fef6a6b42e7aed3e2c8d8b4ab75.zf8.graphql.fabric.microsoft.com/v1/workspaces/f8266fef-6a6b-42e7-aed3-e2c8d8b4ab75/graphqlapis/131cccec-674e-403a-944b-8d3576fd7921/graphql"
# If using Azure API Management, uncomment and set the subscription key
# APIM_SUBSCRIPTION_KEY="your-subscription-key"
# If using authentication, uncomment and set the token
# AUTH_TOKEN="your-auth-token"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Legrand IoT Data GraphQL Query Script${NC}"
echo "======================================"

# Function to execute GraphQL query
execute_query() {
    local query="$1"
    local description="$2"
    
    echo -e "\n${YELLOW}Executing: $description${NC}"
    echo "Query: $query"
    echo "Endpoint: $GRAPHQL_ENDPOINT"
    
    # Build curl command with headers
    local headers=(
        "-H" "Content-Type: application/json"
    )
    
    # Add API Management subscription key if set
    if [ ! -z "$APIM_SUBSCRIPTION_KEY" ]; then
        headers+=("-H" "Ocp-Apim-Subscription-Key: $APIM_SUBSCRIPTION_KEY")
    fi
    
    # Add authorization header if set
    if [ ! -z "$AUTH_TOKEN" ]; then
        headers+=("-H" "Authorization: Bearer $AUTH_TOKEN")
    fi
    
    # Execute the curl command
    curl -X POST "$GRAPHQL_ENDPOINT" \
        "${headers[@]}" \
        -d "{\"query\": \"$query\"}" \
        -w "\n\nHTTP Status: %{http_code}\nTotal Time: %{time_total}s\n" \
        -s
    
    echo -e "\n${GREEN}Query completed${NC}"
    echo "----------------------------------------"
}

# Query 1: Get all IoT data (first 10 items)
QUERY_ALL='query {
  legrand_iot_datas(first: 10) {
    items {
      Timestamp
      BuildingID
      DeviceID
      Location
      MetricType
      Value
      Unit
      Status
    }
    hasNextPage
    endCursor
  }
}'
execute_query "$QUERY_ALL" "Get first 10 IoT data records"

# Query 2: Filter by specific building
QUERY_BUILDING='query {
  legrand_iot_datas(
    first: 5,
    filter: {
      BuildingID: { eq: "BUILDING-001" }
    }
  ) {
    items {
      Timestamp
      BuildingID
      DeviceID
      Location
      MetricType
      Value
      Unit
      Status
    }
  }
}'
execute_query "$QUERY_BUILDING" "Get IoT data for specific building"

# Query 3: Filter by metric type and sort by timestamp
QUERY_TEMPERATURE='query {
  legrand_iot_datas(
    first: 10,
    filter: {
      MetricType: { eq: "temperature" }
    },
    orderBy: {
      Timestamp: DESC
    }
  ) {
    items {
      Timestamp
      BuildingID
      DeviceID
      Location
      MetricType
      Value
      Unit
      Status
    }
  }
}'
execute_query "$QUERY_TEMPERATURE" "Get temperature readings sorted by timestamp"

# Query 4: Get data with value range filter
QUERY_VALUE_RANGE='query {
  legrand_iot_datas(
    first: 10,
    filter: {
      Value: { 
        gte: 20.0,
        lte: 30.0
      }
    }
  ) {
    items {
      Timestamp
      BuildingID
      DeviceID
      Location
      MetricType
      Value
      Unit
      Status
    }
  }
}'
execute_query "$QUERY_VALUE_RANGE" "Get IoT data with values between 20-30"

# Query 5: Complex filter with multiple conditions
QUERY_COMPLEX='query {
  legrand_iot_datas(
    first: 5,
    filter: {
      and: [
        { MetricType: { eq: "energy" } },
        { Status: { eq: "active" } },
        { Value: { gt: 0 } }
      ]
    },
    orderBy: {
      Value: DESC
    }
  ) {
    items {
      Timestamp
      BuildingID
      DeviceID
      Location
      MetricType
      Value
      Unit
      Status
    }
  }
}'
execute_query "$QUERY_COMPLEX" "Get active energy readings with positive values"

# Query 6: Aggregation example - get maximum and average values
QUERY_AGGREGATION='query {
  legrand_iot_datas(first: 1) {
    groupBy(fields: [MetricType]) {
      fields {
        MetricType
      }
      aggregations {
        max(field: Value)
        avg(field: Value)
        min(field: Value)
        count(field: Value)
      }
    }
  }
}'
execute_query "$QUERY_AGGREGATION" "Get aggregated data by metric type"

# Query 7: Pagination example
QUERY_PAGINATION='query {
  legrand_iot_datas(first: 3) {
    items {
      Timestamp
      DeviceID
      MetricType
      Value
    }
    hasNextPage
    endCursor
  }
}'
execute_query "$QUERY_PAGINATION" "Get paginated results (first 3 items)"

echo -e "\n${GREEN}All queries completed!${NC}"
echo -e "${YELLOW}Note: Update the GRAPHQL_ENDPOINT variable at the top of this script with your actual GraphQL endpoint.${NC}"
echo -e "${YELLOW}If using authentication, set the AUTH_TOKEN or APIM_SUBSCRIPTION_KEY variables.${NC}"