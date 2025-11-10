#!/bin/bash

# Demo script showing example usage of the GitHub GraphQL Client
# This script shows the commands but doesn't execute them (requires a real token)

echo "=========================================="
echo "GitHub GraphQL Client - Usage Examples"
echo "=========================================="
echo ""

echo "1. Setup Instructions:"
echo "   cp .env.example .env"
echo "   # Edit .env and add your GitHub token"
echo ""

echo "2. View your authenticated user information:"
echo "   python github_graphql_client.py viewer"
echo ""

echo "3. List repositories for a user:"
echo "   python github_graphql_client.py repos octocat"
echo ""

echo "4. List top 5 repositories for a user:"
echo "   python github_graphql_client.py repos torvalds --limit 5"
echo ""

echo "5. Get detailed information about a repository:"
echo "   python github_graphql_client.py repo octocat Hello-World"
echo ""

echo "=========================================="
echo "For more information, see README.md"
echo "=========================================="
