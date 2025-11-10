# GitHub GraphQL API Python Sample

A command-line application demonstrating how to use GitHub's GraphQL API with personal access token authentication.

## Features

- **Authenticated User Information**: View details about the currently authenticated GitHub user
- **User Repositories**: List repositories for any GitHub user
- **Repository Details**: Get detailed information about a specific repository
- **GraphQL API Integration**: Direct interaction with GitHub's GraphQL API
- **Personal Access Token Authentication**: Secure authentication using GitHub PAT

## Prerequisites

- Python 3.7 or higher
- GitHub Personal Access Token
- Internet connection

## Installation

1. Clone this repository or navigate to the `github-graphql-sample` directory:

```bash
cd github-graphql-sample
```

2. Install the required Python packages:

```bash
pip install -r requirements.txt
```

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

2. Create a `.env` file in the `github-graphql-sample` directory:

```bash
cp .env.example .env
```

3. Edit the `.env` file and replace `your_github_personal_access_token_here` with your actual token:

```
GITHUB_TOKEN=ghp_your_actual_token_here
```

## Usage

The application provides three main commands:

### 1. View Authenticated User Information

Display information about the user associated with the GitHub token:

```bash
python github_graphql_client.py viewer
```

**Example Output:**
```
GitHub User Information
==================================================
Username:     octocat
Name:         The Octocat
Email:        octocat@github.com
Bio:          GitHub's mascot
Company:      @github
Location:     San Francisco
Created At:   2011-01-25T18:44:36Z
Followers:    5000
Following:    0
Repositories: 8
```

### 2. List User Repositories

List the most recently updated repositories for a specific user:

```bash
python github_graphql_client.py repos <username>
```

You can also specify the number of repositories to display (default is 10):

```bash
python github_graphql_client.py repos <username> --limit 5
```

**Example:**
```bash
python github_graphql_client.py repos octocat
```

**Example Output:**
```
Top 10 Repositories for octocat
==================================================

1. Hello-World (Public)
   URL:         https://github.com/octocat/Hello-World
   Description: My first repository on GitHub!
   Language:    JavaScript
   Stars:       2000
   Forks:       500
   Updated:     2024-01-15T10:30:00Z
```

### 3. Get Repository Details

Display detailed information about a specific repository:

```bash
python github_graphql_client.py repo <owner> <repository-name>
```

**Example:**
```bash
python github_graphql_client.py repo octocat Hello-World
```

**Example Output:**
```
Repository: Hello-World (Public)
==================================================
URL:              https://github.com/octocat/Hello-World
Description:      My first repository on GitHub!
Default Branch:   main
Primary Language: JavaScript
Languages:        JavaScript, HTML, CSS
Stars:            2000
Forks:            500
Watchers:         150
Issues:           5
Pull Requests:    2
Created At:       2011-01-26T19:01:12Z
Updated At:       2024-01-15T10:30:00Z
```

## Understanding GraphQL

This application uses GraphQL to query GitHub's API. GraphQL allows you to:

- **Request exactly what you need**: Specify the exact fields you want in the response
- **Get multiple resources in a single request**: Reduce the number of API calls
- **Strongly typed**: The API schema defines what queries are possible

### Example GraphQL Query

Here's a simple query used in this application to get user information:

```graphql
query {
  viewer {
    login
    name
    email
    followers {
      totalCount
    }
  }
}
```

This query:
- Requests information about the authenticated user (`viewer`)
- Only retrieves the specific fields we need (`login`, `name`, `email`, and follower count)

## Project Structure

```
github-graphql-sample/
├── github_graphql_client.py  # Main application code
├── requirements.txt           # Python dependencies
├── .env.example              # Example environment file
├── .env                      # Your actual environment file (not committed)
└── README.md                 # This file
```

## Code Overview

The application consists of several key components:

### GitHubGraphQLClient Class

A client class that handles:
- Authentication with GitHub's API
- Executing GraphQL queries
- Error handling

### Query Functions

- `get_viewer_info()`: Fetches authenticated user information
- `get_user_repositories()`: Retrieves a user's repositories
- `get_repository_info()`: Gets detailed information about a specific repository

### Command-Line Interface

Uses Python's `argparse` module to provide a user-friendly CLI with multiple subcommands.

## Troubleshooting

### "GITHUB_TOKEN environment variable is not set"

Make sure you've:
1. Created a `.env` file in the same directory as the script
2. Added your GitHub token to the `.env` file
3. The token is in the format: `GITHUB_TOKEN=ghp_...`

### "API request failed" or authentication errors

- Verify your token is valid and hasn't expired
- Check that your token has the required scopes (`read:user`, `repo`)
- Ensure your token is correctly copied without extra spaces

### "User not found" or "Repository not found"

- Check the spelling of the username or repository name
- Ensure the repository is accessible (public or accessible with your token)

## Security Best Practices

- **Never commit your `.env` file**: It contains your personal access token
- **Use environment variables**: Keep tokens out of your code
- **Rotate tokens regularly**: Generate new tokens periodically
- **Use minimal scopes**: Only grant the permissions your application needs
- **Revoke unused tokens**: Remove tokens you're no longer using

## Further Learning

- [GitHub GraphQL API Documentation](https://docs.github.com/en/graphql)
- [GraphQL Official Documentation](https://graphql.org/learn/)
- [GitHub GraphQL Explorer](https://docs.github.com/en/graphql/overview/explorer) - Interactive tool to test queries

## Contributing

Feel free to extend this sample application with additional features:
- Search for repositories
- Create or update issues
- Fetch pull request information
- List organization members
- And much more using GitHub's GraphQL API!

## License

This sample application is provided as-is for educational purposes.
