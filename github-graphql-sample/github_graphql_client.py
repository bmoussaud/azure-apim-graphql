#!/usr/bin/env python3
"""
GitHub GraphQL API Sample Application

A command-line application demonstrating how to use GitHub's GraphQL API
with personal access token authentication.
"""

import os
import sys
import json
import argparse
from typing import Dict, Any, Optional
import requests
from dotenv import load_dotenv


class GitHubGraphQLClient:
    """Client for interacting with GitHub's GraphQL API."""

    

    def __init__(self, token: str, api_url: Optional[str] = "https://api.github.com/graphql", extra_headers: Optional[Dict[str, str]] = None) -> None:
        """
        Initialize the GitHub GraphQL client.

        Args:
            token: GitHub personal access token
        """
        self.token = token
        self.headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        }
        self.headers.update(extra_headers or {})
        self.api_url = api_url

    def execute_query(
        self, query: str, variables: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Execute a GraphQL query against GitHub's API.

        Args:
            query: GraphQL query string
            variables: Optional variables for the query

        Returns:
            Response data from the API

        Raises:
            requests.RequestException: If the API request fails
        """
        payload = {"query": query}
        if variables:
            payload["variables"] = variables

        response = requests.post(
            self.api_url, headers=self.headers, json=payload, timeout=30
        )
        response.raise_for_status()

        result = response.json()

        if "errors" in result:
            raise Exception(f"GraphQL errors: {json.dumps(result['errors'], indent=2)}")

        return result


def get_viewer_info(client: GitHubGraphQLClient) -> None:
    """
    Fetch and display information about the authenticated user.

    Args:
        client: GitHubGraphQLClient instance
    """
    query = """
    query {
        viewer {
            login
            name
            email
            bio
            company
            location
            createdAt
            followers {
                totalCount
            }
            following {
                totalCount
            }
            repositories {
                totalCount
            }
        }
    }
    """

    print("Fetching authenticated user information...\n")
    result = client.execute_query(query)
    viewer = result["data"]["viewer"]

    print(f"GitHub User Information")
    print(f"=" * 50)
    print(f"Username:     {viewer['login']}")
    print(f"Name:         {viewer.get('name', 'N/A')}")
    print(f"Email:        {viewer.get('email', 'N/A')}")
    print(f"Bio:          {viewer.get('bio', 'N/A')}")
    print(f"Company:      {viewer.get('company', 'N/A')}")
    print(f"Location:     {viewer.get('location', 'N/A')}")
    print(f"Created At:   {viewer['createdAt']}")
    print(f"Followers:    {viewer['followers']['totalCount']}")
    print(f"Following:    {viewer['following']['totalCount']}")
    print(f"Repositories: {viewer['repositories']['totalCount']}")
    print()


def get_user_repositories(
    client: GitHubGraphQLClient, username: str, limit: int = 10
) -> None:
    """
    Fetch and display repositories for a specific user.

    Args:
        client: GitHubGraphQLClient instance
        username: GitHub username
        limit: Number of repositories to fetch (default: 10)
    """
    query = """
    query($username: String!, $limit: Int!) {
        user(login: $username) {
            login
            repositories(first: $limit, orderBy: {field: UPDATED_AT, direction: DESC}) {
                nodes {
                    name
                    description
                    url
                    stargazerCount
                    forkCount
                    isPrivate
                    primaryLanguage {
                        name
                    }
                    updatedAt
                }
            }
        }
    }
    """

    variables = {"username": username, "limit": limit}

    print(f"Fetching repositories for user '{username}'...\n")
    result = client.execute_query(query, variables)

    user = result["data"]["user"]
    if not user:
        print(f"User '{username}' not found.")
        return

    repositories = user["repositories"]["nodes"]

    print(f"Top {len(repositories)} Repositories for {user['login']}")
    print(f"=" * 50)

    for i, repo in enumerate(repositories, 1):
        language = repo["primaryLanguage"]["name"] if repo["primaryLanguage"] else "N/A"
        visibility = "Private" if repo["isPrivate"] else "Public"

        print(f"\n{i}. {repo['name']} ({visibility})")
        print(f"   URL:         {repo['url']}")
        print(f"   Description: {repo.get('description', 'No description')}")
        print(f"   Language:    {language}")
        print(f"   Stars:       {repo['stargazerCount']}")
        print(f"   Forks:       {repo['forkCount']}")
        print(f"   Updated:     {repo['updatedAt']}")
    print()


def get_repository_info(client: GitHubGraphQLClient, owner: str, name: str) -> None:
    """
    Fetch and display detailed information about a specific repository.

    Args:
        client: GitHubGraphQLClient instance
        owner: Repository owner
        name: Repository name
    """
    query = """
    query($owner: String!, $name: String!) {
        repository(owner: $owner, name: $name) {
            name
            description
            url
            isPrivate
            stargazerCount
            forkCount
            watchers {
                totalCount
            }
            issues {
                totalCount
            }
            pullRequests {
                totalCount
            }
            primaryLanguage {
                name
            }
            languages(first: 5) {
                nodes {
                    name
                }
            }
            createdAt
            updatedAt
            defaultBranchRef {
                name
            }
        }
    }
    """

    variables = {"owner": owner, "name": name}

    print(f"Fetching repository information for '{owner}/{name}'...\n")
    result = client.execute_query(query, variables)

    repo = result["data"]["repository"]
    if not repo:
        print(f"Repository '{owner}/{name}' not found.")
        return

    languages = [lang["name"] for lang in repo["languages"]["nodes"]]
    primary_language = (
        repo["primaryLanguage"]["name"] if repo["primaryLanguage"] else "N/A"
    )
    visibility = "Private" if repo["isPrivate"] else "Public"

    print(f"Repository: {repo['name']} ({visibility})")
    print(f"=" * 50)
    print(f"URL:              {repo['url']}")
    print(f"Description:      {repo.get('description', 'No description')}")
    print(
        f"Default Branch:   {repo['defaultBranchRef']['name'] if repo['defaultBranchRef'] else 'N/A'}"
    )
    print(f"Primary Language: {primary_language}")
    print(f"Languages:        {', '.join(languages) if languages else 'N/A'}")
    print(f"Stars:            {repo['stargazerCount']}")
    print(f"Forks:            {repo['forkCount']}")
    print(f"Watchers:         {repo['watchers']['totalCount']}")
    print(f"Issues:           {repo['issues']['totalCount']}")
    print(f"Pull Requests:    {repo['pullRequests']['totalCount']}")
    print(f"Created At:       {repo['createdAt']}")
    print(f"Updated At:       {repo['updatedAt']}")
    print()


def main():
    """Main entry point for the application."""
    parser = argparse.ArgumentParser(
        description="GitHub GraphQL API Sample Application",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Show authenticated user info
  python github_graphql_client.py viewer
  
  # List repositories for a user
  python github_graphql_client.py repos octocat
  
  # Get detailed repository info
  python github_graphql_client.py repo octocat Hello-World
        """,
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Viewer command
    subparsers.add_parser("viewer", help="Show authenticated user information")

    # Repositories command
    repos_parser = subparsers.add_parser("repos", help="List user repositories")
    repos_parser.add_argument("username", help="GitHub username")
    repos_parser.add_argument(
        "--limit",
        type=int,
        default=10,
        help="Number of repositories to show (default: 10)",
    )

    # Repository command
    repo_parser = subparsers.add_parser("repo", help="Show repository details")
    repo_parser.add_argument("owner", help="Repository owner")
    repo_parser.add_argument("name", help="Repository name")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    # Load environment variables from .env file
    load_dotenv()

    # Get GitHub token from environment
    github_token = os.getenv("GITHUB_TOKEN")
    if not github_token:
        print("Error: GITHUB_TOKEN environment variable is not set.", file=sys.stderr)
        print(
            "Please create a .env file with your GitHub personal access token.",
            file=sys.stderr,
        )
        print("You can copy .env.example to .env and add your token.", file=sys.stderr)
        sys.exit(1)

    github_graphql_api_url = os.getenv("GITHUB_GRAPHQL_API_URL", "https://api.github.com/graphql")

    # Create GitHub GraphQL client
    try:
        client = GitHubGraphQLClient(github_token, api_url=github_graphql_api_url,extra_headers={"Ocp-Apim-Subscription-Key": os.getenv("GITHUB_APIM_SUBSCRIPTION_KEY")} if os.getenv("GITHUB_APIM_SUBSCRIPTION_KEY") else None)
        # Execute the requested command
        if args.command == "viewer":
            get_viewer_info(client)
        elif args.command == "repos":
            get_user_repositories(client, args.username, args.limit)
        elif args.command == "repo":
            get_repository_info(client, args.owner, args.name)

    except requests.RequestException as e:
        print(f"Error: API request failed: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
