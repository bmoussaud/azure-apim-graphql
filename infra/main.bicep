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

@description('Environment name (e.g., dev, test, prod)')
param environment string = 'dev'

@description('Tags to apply to all resources')
param tags object = {
  Environment: environment
  ManagedBy: 'Bicep'
}

// Generate unique resource names
var appInsightsName = '${baseName}-ai-${environment}'
var apimName = '${baseName}-apim-${environment}'

// Deploy Application Insights
module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsights-deployment'
  params: {
    appInsightsName: appInsightsName
    location: location
    tags: tags
  }
}

// Deploy API Management
module apim 'modules/apim.bicep' = {
  name: 'apim-deployment'
  params: {
    apimName: apimName
    location: location
    publisherEmail: publisherEmail
    publisherName: publisherName
    sku: apimSku
    capacity: apimCapacity
    tags: tags
    appInsightsId: appInsights.outputs.appInsightsId
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
  }
}

@description('The name of the Application Insights instance')
output appInsightsName string = appInsights.outputs.appInsightsName

@description('The name of the API Management instance')
output apimName string = apim.outputs.apimName

@description('The gateway URL of the API Management instance')
output apimGatewayUrl string = apim.outputs.apimGatewayUrl

@description('The portal URL of the API Management instance')
output apimPortalUrl string = apim.outputs.apimPortalUrl
