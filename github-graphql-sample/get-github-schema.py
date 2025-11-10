#!/usr/bin/env python3
"""
GitHub GraphQL Schema Fetcher

This script fetches the GitHub GraphQL schema using a simplified approach
and saves it in a format suitable for Azure API Management.
"""

import os
import json
import requests
from dotenv import load_dotenv

def get_github_graphql_schema(token: str) -> str:
    """
    Fetch a simplified GitHub GraphQL schema representation.
    
    Args:
        token: GitHub personal access token
        
    Returns:
        GraphQL schema information as text
    """
    
    # Simple query to test connectivity and get basic schema info
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
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "User-Agent": "GraphQL Schema Fetcher"
    }
    
    payload = {"query": test_query}
    
    print(f"📡 Sending request to GitHub GraphQL API...")
    response = requests.post(
        "https://api.github.com/graphql",
        headers=headers,
        json=payload,
        timeout=30
    )
    
    print(f"📊 Response status: {response.status_code}")
    
    if response.status_code != 200:
        print(f"❌ HTTP Error: {response.status_code}")
        print(f"Response: {response.text}")
        return None
        
    response.raise_for_status()
    
    result = response.json()
    
    if "errors" in result:
        print(f"❌ GraphQL errors: {json.dumps(result['errors'], indent=2)}")
        return None
    
    return result["data"]

def create_minimal_schema() -> str:
    """
    Create a minimal GraphQL schema for testing with APIM.
    
    This is a basic schema that can be used as a starting point.
    """
    return '''
"""GitHub GraphQL API Schema (Minimal)"""

type Query {
  """
  Lookup a user by login.
  """
  user(login: String!): User
  
  """
  The currently authenticated user.
  """
  viewer: User
}

"""
A user is an individual's account on GitHub that owns repositories and can make new content.
"""
type User {
  """
  The user's public profile name.
  """
  name: String
  
  """
  The username used to login.
  """
  login: String!
  
  """
  The user's public profile email.
  """
  email: String
  
  """
  The user's public profile bio.
  """
  bio: String
  
  """
  A list of repositories that the user owns.
  """
  repositories(first: Int, after: String): RepositoryConnection
}

"""
A list of repositories owned by the subject.
"""
type RepositoryConnection {
  """
  A list of nodes.
  """
  nodes: [Repository]
  
  """
  Information to aid in pagination.
  """
  pageInfo: PageInfo
}

"""
A repository contains the content for a project.
"""
type Repository {
  """
  The name of the repository.
  """
  name: String!
  
  """
  The description of the repository.
  """
  description: String
  
  """
  The HTTP URL for this repository
  """
  url: String!
  
  """
  Identifies if the repository is private or internal.
  """
  isPrivate: Boolean!
}

"""
Information about pagination in a connection.
"""
type PageInfo {
  """
  When paginating forwards, the cursor to continue.
  """
  endCursor: String
  
  """
  When paginating forwards, are there more items?
  """
  hasNextPage: Boolean!
}
'''

def main():
    """Main function."""
    print("🚀 GitHub GraphQL Schema Fetcher for Azure API Management")
    print("=" * 60)
    
    # Try to load environment variables
    load_dotenv()
    
    # Get GitHub token
    github_token = os.getenv("GITHUB_TOKEN")
    if not github_token:
        print("⚠️  GITHUB_TOKEN not found in environment.")
        print("📝 Creating a minimal schema file without API introspection...")
        
        # Create minimal schema
        schema_content = create_minimal_schema()
        output_file = "github-schema-minimal.graphql"
        
    else:
        print(f"🔑 Found GitHub token (length: {len(github_token)})")
        
        try:
            schema_data = get_github_graphql_schema(github_token)
            
            if schema_data:
                print("✅ Successfully connected to GitHub GraphQL API!")
                print(f"📋 Schema info:")
                schema_info = schema_data.get("__schema", {})
                print(f"   Query type: {schema_info.get('queryType', {}).get('name', 'Unknown')}")
                print(f"   Mutation type: {schema_info.get('mutationType', {}).get('name', 'None')}")
                print(f"   Subscription type: {schema_info.get('subscriptionType', {}).get('name', 'None')}")
                print(f"   Total types: {len(schema_info.get('types', []))}")
                
                # For now, create the minimal schema with a note
                schema_content = f"""# GitHub GraphQL API Schema
# Connection successful! Found {len(schema_info.get('types', []))} types
# 
# Note: This is a minimal schema for Azure API Management testing.
# For the full schema, consider using GraphQL introspection tools or
# GitHub's schema.docs.graphql file from their public repository.

{create_minimal_schema()}"""
                output_file = "github-schema-connected.graphql"
            else:
                print("❌ Failed to fetch schema data.")
                schema_content = create_minimal_schema()
                output_file = "github-schema-minimal.graphql"
                
        except Exception as e:
            print(f"❌ Error: {e}")
            print("📝 Creating minimal schema as fallback...")
            schema_content = create_minimal_schema()
            output_file = "github-schema-minimal.graphql"
    
    # Save schema to file
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(schema_content)
    
    print(f"\n✅ Schema saved to: {output_file}")
    print(f"📁 File size: {len(schema_content)} characters")
    
    print(f"\n🔧 Next steps for Azure API Management:")
    print("1. In Azure Portal, go to your API Management instance")
    print("2. Navigate to APIs > Add API > GraphQL")
    print("3. Select 'Synthetic GraphQL' instead of 'Pass-through'")
    print(f"4. Upload the generated '{output_file}' file")
    print("5. Configure resolvers to point to GitHub's GraphQL endpoint")
    print("   - Set backend URL to: https://api.github.com/graphql")
    print("   - Add authentication policy with your GitHub token")
    
    print(f"\n📖 Alternative approach:")
    print("1. Use 'Pass-through GraphQL' mode in APIM")
    print("2. Set GraphQL endpoint to: https://api.github.com/graphql")
    print("3. Don't upload schema file (leave blank)")
    print("4. Add inbound policy for authentication:")
    print('   <set-header name="Authorization" exists-action="override">')
    print('     <value>Bearer YOUR_GITHUB_TOKEN</value>')
    print('   </set-header>')

if __name__ == "__main__":
    main()