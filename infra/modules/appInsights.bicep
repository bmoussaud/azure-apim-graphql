@description('The name of the Application Insights instance')
param appInsightsName string

@description('The location where the Application Insights instance will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the Application Insights instance')
param tags object = {}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('The ID of the Application Insights instance')
output appInsightsId string = appInsights.id

@description('The name of the Application Insights instance')
output appInsightsName string = appInsights.name

@description('The instrumentation key of the Application Insights instance')
output instrumentationKey string = appInsights.properties.InstrumentationKey
