/**
 * @module policy-v1
 * @description This module defines the API resources using Bicep.
 * It includes configurations for creating and managing APIs, products, and policies.
 */
@description('The name of the API Management instance. Defaults to "apim-<resourceSuffix>".')
param apimName string

@description('The name of the api')
param apiName string  

@description('The operation name for the API.')
param operationName string 

@description('The API configuration object.')
param policyXml string = ''

// https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service
resource apimService 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimName
}

// https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis
resource apimApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' existing = {
  name: apiName
  parent: apimService
 
}

// https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis/policies
resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' =  {
  name: 'policy'
  parent: apimApi
  properties: {
    
    format: 'rawxml' // only use 'rawxml' for policies as it's what APIM expects and means we don't need to escape XML characters
    value: policyXml
  }
}

// ------------------------------
//    OUTPUTS
// ------------------------------

@description('The resource ID of the created API.')
output apiResourceId string = apimApi.id

@description('The name of the created API.')
output apiName string = apimApi.name

@description('The display name of the created API.')
output apiDisplayName string = apimApi.properties.displayName

@description('The path of the created API.')
output apiPath string = apimApi.properties.path

