@description('The location where resources will be deployed')
param location string = resourceGroup().location

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@description('GitHub Personal Access Token for GraphQL API access')
@secure()
param githubToken string

@description('Tags to apply to all resources')
param tags object = {
  Environment: environmentName
  ManagedBy: 'Bicep'
}

#disable-next-line no-unused-vars
var resourceToken = toLower(uniqueString(resourceGroup().id, environmentName, location))

module applicationInsights 'modules/app-insights.bicep' = {
  name: 'application-insights'
  params: {
    location: location
    workspaceName: logAnalyticsWorkspace.outputs.name
    applicationInsightsName: 'app-insights-${resourceToken}'
    tags: tags
  }
}

module logAnalyticsWorkspace 'modules/log-analytics-workspace.bicep' = {
  name: 'log-analytics-workspace'
  params: {
    location: location
    logAnalyticsName: 'log-analytics-${resourceToken}'
    tags: tags
  }
}

module apiManagement 'modules/api-management.bicep' = {
  name: 'api-management'
  params: {
    location: location
    tags: tags
    serviceName: 'apim-${resourceToken}'
    publisherName: 'GraphQL Apps'
    publisherEmail: '${environmentName}@contososuites.com'
    skuName: 'Basicv2'
    skuCount: 1
    aiName: applicationInsights.outputs.aiName

  }
}

module githubGraphqlApi 'modules/graphql-api.bicep' = {
  name: 'github-graphql-api'
  params: {
    apimName: apiManagement.outputs.name
    appInsightsId: applicationInsights.outputs.aiId
    appInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    
    api: {
      name: 'github-graphql-api'
      description: 'Github API'
      displayName: 'Github API'
      path: '/github-graphql'
      serviceUrl: 'https://api.github.com/graphql'
      subscriptionRequired: true
      tags: ['github', 'api', 'graphql']
      policyXml: loadTextContent('../github-graphql-sample/github-graphql-policy.xml')
      schema: loadTextContent('../github-graphql-sample/github-schema-minimal.graphql')
      namedValues: {}
      secretNamedValues: {
        'graphql-github-token': githubToken
      }
    }
    
  }
}

module githubRest2GraphqlApi 'modules/api.bicep' = {
  name: 'github-rest-to-graphql-api'
  params: {
    apimName: apiManagement.outputs.name
    appInsightsId: applicationInsights.outputs.aiId
    appInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    
    api: {
      name: 'github-rest-to-graphql-api'
      description: 'Rest to GraphQL Github API'
      displayName: 'Rest to GraphQL Github API'
      path: '/github-rest-to-graphql'
      serviceUrl: 'https://api.github.com/graphql'
      subscriptionRequired: true
      tags: ['github', 'api', 'rest']
      policyXml: loadTextContent('../github-rest-2-graphql/github-rest-to-graphql-policy-base.xml')
      value: loadTextContent('../github-rest-2-graphql/swagger.json')
      namedValues: {}
      secretNamedValues: {
        'graphql-github-token': githubToken
      }
    }
    
  }
}

output APIM_GATEWAY_URL string = apiManagement.outputs.apiManagementProxyHostName
output GITHUB_APIM_SUBSCRIPTION_KEY string = githubGraphqlApi.outputs.subscriptionPrimaryKey
output GITHUB_GRAPHQL_API_URL string = 'https://${apiManagement.outputs.apiManagementProxyHostName}/github-graphql'

output APIM_NAME string = apiManagement.outputs.name
output GITHUB_TOKEN string = githubToken
output OAUTH_TENANT_ID string = tenant().tenantId
output SUBSCRIPTION_ID string = subscription().subscriptionId
