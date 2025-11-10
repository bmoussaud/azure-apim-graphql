@description('The name of the API Management instance')
param apimName string

@description('The location where the API Management instance will be deployed')
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
param sku string = 'Standard'

@description('The capacity of the API Management instance')
param capacity int = 1

@description('Tags to apply to the API Management instance')
param tags object = {}

@description('The ID of the Application Insights instance')
param appInsightsId string = ''

@description('The instrumentation key of the Application Insights instance')
@secure()
param appInsightsInstrumentationKey string = ''

resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apimName
  location: location
  tags: tags
  sku: {
    name: sku
    capacity: capacity
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Configure Application Insights logger if provided
resource apimLogger 'Microsoft.ApiManagement/service/loggers@2023-05-01-preview' = if (!empty(appInsightsId)) {
  parent: apim
  name: 'applicationinsights'
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

// Configure diagnostic settings to use Application Insights
resource apimDiagnostics 'Microsoft.ApiManagement/service/diagnostics@2023-05-01-preview' = if (!empty(appInsightsId)) {
  parent: apim
  name: 'applicationinsights'
  properties: {
    loggerId: apimLogger.id
    alwaysLog: 'allErrors'
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    httpCorrelationProtocol: 'W3C'
  }
}

@description('The ID of the API Management instance')
output apimId string = apim.id

@description('The name of the API Management instance')
output apimName string = apim.name

@description('The gateway URL of the API Management instance')
output apimGatewayUrl string = apim.properties.gatewayUrl

@description('The portal URL of the API Management instance')
output apimPortalUrl string = apim.properties.portalUrl
