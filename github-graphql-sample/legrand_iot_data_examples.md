# Legrand IoT Data - Simple curl Examples

## Configuration
Before running these commands, set your GraphQL endpoint and authentication:

```bash
# Set your GraphQL endpoint
export GRAPHQL_ENDPOINT="https://your-graphql-endpoint.com/graphql"

# If using Azure API Management, set subscription key
export APIM_SUBSCRIPTION_KEY="your-subscription-key"

# If using Bearer token authentication
export AUTH_TOKEN="your-auth-token"
```

## Basic Queries

### 1. Get all IoT data (first 10 records)
```bash
curl -X POST "$GRAPHQL_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Ocp-Apim-Subscription-Key: $APIM_SUBSCRIPTION_KEY" \
  -d '{
    "query": "query { legrand_iot_datas(first: 10) { items { Timestamp BuildingID DeviceID Location MetricType Value Unit Status } hasNextPage endCursor } }"
  }'
```



### 2. Filter by specific building
```bash
curl -X POST "$GRAPHQL_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Ocp-Apim-Subscription-Key: $APIM_SUBSCRIPTION_KEY" \
  -d '{
    "query": "query { legrand_iot_datas(first: 5, filter: { BuildingID: { eq: \"BUILDING-001\" } }) { items { Timestamp BuildingID DeviceID Location MetricType Value Unit Status } } }"
  }'
```

### 3. Get temperature readings
```bash
curl -X POST "$GRAPHQL_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Ocp-Apim-Subscription-Key: $APIM_SUBSCRIPTION_KEY" \
  -d '{
    "query": "query { legrand_iot_datas(first: 10, filter: { MetricType: { eq: \"temperature\" } }, orderBy: { Timestamp: DESC }) { items { Timestamp BuildingID DeviceID Location MetricType Value Unit Status } } }"
  }'
```

### 4. Filter by value range
```bash
curl -X POST "$GRAPHQL_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Ocp-Apim-Subscription-Key: $APIM_SUBSCRIPTION_KEY" \
  -d '{
    "query": "query { legrand_iot_datas(first: 10, filter: { Value: { gte: 20.0, lte: 30.0 } }) { items { Timestamp BuildingID DeviceID Location MetricType Value Unit Status } } }"
  }'
```

### 5. Complex filter with multiple conditions
```bash
curl -X POST "$GRAPHQL_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Ocp-Apim-Subscription-Key: $APIM_SUBSCRIPTION_KEY" \
  -d '{
    "query": "query { legrand_iot_datas(first: 5, filter: { and: [{ MetricType: { eq: \"energy\" } }, { Status: { eq: \"active\" } }, { Value: { gt: 0 } }] }, orderBy: { Value: DESC }) { items { Timestamp BuildingID DeviceID Location MetricType Value Unit Status } } }"
  }'
```

### 6. Get aggregated data
```bash
curl -X POST "$GRAPHQL_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Ocp-Apim-Subscription-Key: $APIM_SUBSCRIPTION_KEY" \
  -d '{
    "query": "query { legrand_iot_datas(first: 1) { groupBy(fields: [MetricType]) { fields { MetricType } aggregations { max(field: Value) avg(field: Value) min(field: Value) count(field: Value) } } } }"
  }'
```

## Authentication Options

### Using Bearer Token
```bash
curl -X POST "$GRAPHQL_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d '{"query": "your-query-here"}'
```

### Using Azure API Management Subscription Key
```bash
curl -X POST "$GRAPHQL_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Ocp-Apim-Subscription-Key: $APIM_SUBSCRIPTION_KEY" \
  -d '{"query": "your-query-here"}'
```

### Using both (if required)
```bash
curl -X POST "$GRAPHQL_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Ocp-Apim-Subscription-Key: $APIM_SUBSCRIPTION_KEY" \
  -d '{"query": "your-query-here"}'
```

## Available Filters

Based on the GraphQL schema, you can filter by:
- `Timestamp`: DateTime filters (eq, gt, gte, lt, lte, neq, isNull, in)
- `BuildingID`: String filters (eq, contains, notContains, startsWith, endsWith, neq, isNull, in)
- `DeviceID`: String filters
- `Location`: String filters
- `MetricType`: String filters
- `Value`: Float filters (eq, gt, gte, lt, lte, neq, isNull, in)
- `Unit`: String filters
- `Status`: String filters

## Available Sort Options
You can order by any field in ASC or DESC order:
```json
{
  "orderBy": {
    "Timestamp": "DESC",
    "Value": "ASC"
  }
}
```

## Pagination
Use `first` and `after` for pagination:
```json
{
  "first": 10,
  "after": "cursor-from-previous-query"
}
```