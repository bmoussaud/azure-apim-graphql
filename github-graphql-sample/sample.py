from azure.identity import InteractiveBrowserCredential, DefaultAzureCredential, AzureCliCredential,AzureDeveloperCliCredential

import requests
import json
 
# Acquire a token
# DO NOT USE IN PRODUCTION.
# Below code to acquire token is for development purpose only to test the GraphQL endpoint
# For production, always register an application in a Microsoft Entra ID tenant and use the appropriate client_id and scopes
# https://learn.microsoft.com/en-us/fabric/data-engineering/connect-apps-api-graphql#create-a-microsoft-entra-app
 
app = AzureDeveloperCliCredential(tenant_id="de0dfa5c-3de9-4321-90aa-13727d0ca0b4")
scp = 'https://analysis.windows.net/powerbi/api/user_impersonation'
result = app.get_token(scp)
print("Access token acquired.")
print(f"Token: {result.token}...")  # Print only the first 20 characters for security
 
if not result.token:
    print('Error:', "Could not get access token")
 
# Prepare headers
headers = {
    'Authorization': f'Bearer {result.token}',
    'Content-Type': 'application/json'
}
 
endpoint = 'https://f8266fef6a6b42e7aed3e2c8d8b4ab75.zf8.graphql.fabric.microsoft.com/v1/workspaces/f8266fef-6a6b-42e7-aed3-e2c8d8b4ab75/graphqlapis/245e939b-f666-40db-8d53-be4996c1030b/graphql'
query = """
    query {
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
  }
}
"""

query = """
    query {
    legrand_energy_aggregateds(first: 10) {
        items {
            AggregationTimestamp
        }
    }
    }"""

test_query = """
    query {
      __schema {
        queryType { name }
        mutationType { name }
        subscriptionType { name }
        types {
          name
          kind
          description
        }
      }
    }
    """
 
variables = {
 
  }

 
# Issue GraphQL request
try:
    response = requests.post(endpoint, json={'query': query, 'variables': variables}, headers=headers)
    response.raise_for_status()
    data = response.json()
    print(json.dumps(data, indent=4))
except Exception as error:
    print(f"Query failed with error: {error}")
    raise error