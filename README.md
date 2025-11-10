# Azure API Management - GitHub GraphQL Integration

This repository demonstrates how to integrate GitHub's GraphQL API with Azure API Management (APIM).

## Configuration

1. Create a GitHub Personal Access Token:
   - Go to https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Give it a descriptive name (e.g., "GraphQL Sample App")
   - Select the following scopes:
     - `read:user` - to read user profile information
     - `repo` - to access repository information (required for private repositories)
   - Click "Generate token"
   - **Important**: Copy the token immediately as you won't be able to see it again

2. Edit `infra/main.parameters.json` to set value `githubToken`
3. Trigger the provisioning using `azd provision`

### Testing Your GraphQL API

0. **Settings**
```bash
azd env get-values  > .env
source .env
```

or manually

```bash
cd github-graphql-sample
export GITHUB_TOKEN=your_github_token
export GITHUB_GRAPHQL_API_URL=https://apim-rkh7dxqqe2ol4.azure-api.net/github-graphql
export GITHUB_APIM_SUBSCRIPTION_KEY=your_subscription_key
```

1. **Test with curl using github_api**:
```bash
curl -X POST "https://api.github.com/graphql" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ viewer { login name } }"}'
```

2. **Test with curl**:
```bash
curl -X POST "${GITHUB_GRAPHQL_API_URL}" \
  -H "Ocp-Apim-Subscription-Key: ${GITHUB_APIM_SUBSCRIPTION_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ viewer { login name } }"}'
```

3. **Test with the Python client**:
```bash
uv run python github_graphql_client.py viewer
```

### Sample GraphQL Queries

**Get authenticated user info:**
```graphql
query {
  viewer {
    login
    name
    email
  }
}
```

**Get repository information:**
```graphql
query {
  repository(owner: "octocat", name: "Hello-World") {
    name
    description
    stargazerCount
    forkCount
  }
}
```

## 📚 Additional Resources

- [GitHub GraphQL API Documentation](https://docs.github.com/en/graphql)
- [Azure API Management GraphQL Support](https://docs.microsoft.com/en-us/azure/api-management/graphql-apis-overview)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

