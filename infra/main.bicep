@description('The base name for all resources')
param baseName string

@description('The location where resources will be deployed')
param location string = resourceGroup().location

@description('The email address of the API Management publisher')
param publisherEmail string

@description('The name of the API Management publisher organization')
param publisherName string

@description('The pricing tier of the API Management instance')
@allowed([
  'Developer'
  'Standard'
  'Premium'
  'Basic'
  'Consumption'
])
param apimSku string = 'Standard'

@description('The capacity of the API Management instance')
param apimCapacity int = 1

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

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

output APIM_NAME string = apiManagement.outputs.name
output APIM_GATEWAY_URL string = apiManagement.outputs.apiManagementProxyHostName

output OAUTH_TENANT_ID string = tenant().tenantId
output SUBSCRIPTION_ID string = subscription().subscriptionId
