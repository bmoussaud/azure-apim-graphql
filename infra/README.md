# Azure API Management Infrastructure

This folder contains Bicep templates for deploying Azure API Management (APIM) with Application Insights integration.

## Architecture

The infrastructure includes:

- **Azure API Management**: A fully managed API gateway with Standard tier configuration
- **Application Insights**: Monitoring and diagnostics for the API Management instance
- **Integration**: APIM is configured to send logs and metrics to Application Insights

## Files

- `main.bicep`: Main orchestration template that deploys all resources
- `main.parameters.json`: Sample parameters file (update with your values)
- `modules/apim.bicep`: Azure API Management module
- `modules/appInsights.bicep`: Application Insights module

## Prerequisites

- Azure CLI installed ([Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- An Azure subscription
- Appropriate permissions to create resources in Azure

## Deployment

### 1. Login to Azure

```bash
az login
```

### 2. Set your subscription (if you have multiple)

```bash
az account set --subscription <subscription-id>
```

### 3. Create a resource group

```bash
az group create --name rg-apim-graphql --location eastus
```

### 4. Deploy the infrastructure

Update the `main.parameters.json` file with your desired values, then deploy:

```bash
az deployment group create \
  --resource-group rg-apim-graphql \
  --template-file main.bicep \
  --parameters main.parameters.json
```

Or deploy with inline parameters:

```bash
az deployment group create \
  --resource-group rg-apim-graphql \
  --template-file main.bicep \
  --parameters baseName=graphql \
               publisherEmail=admin@contoso.com \
               publisherName=Contoso \
               apimSku=Standard \
               environment=dev
```

## Parameters

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `baseName` | Base name for all resources | - | Yes |
| `location` | Azure region for deployment | Resource Group location | No |
| `publisherEmail` | Email address of the API publisher | - | Yes |
| `publisherName` | Name of the API publisher organization | - | Yes |
| `apimSku` | API Management SKU (Developer, Basic, Standard, Premium, Consumption) | Standard | No |
| `apimCapacity` | Number of deployed units | 1 | No |
| `environment` | Environment name (dev, test, prod) | dev | No |

## Outputs

After deployment, the following outputs will be available:

- `appInsightsName`: Name of the Application Insights instance
- `apimName`: Name of the API Management instance
- `apimGatewayUrl`: Gateway URL for the API Management instance
- `apimPortalUrl`: Developer portal URL for the API Management instance

## Configuration

### API Management

- **SKU**: Standard (can be changed via parameters)
- **Capacity**: 1 unit (can be scaled via parameters)
- **Identity**: System-assigned managed identity enabled
- **Monitoring**: Integrated with Application Insights

### Application Insights

- **Type**: Web application
- **Data Retention**: 90 days
- **Sampling**: 100% (all errors logged)
- **Correlation Protocol**: W3C

## Customization

### Change SKU or Capacity

Edit `main.parameters.json`:

```json
{
  "apimSku": {
    "value": "Premium"
  },
  "apimCapacity": {
    "value": 2
  }
}
```

### Add Custom Tags

Edit the `tags` parameter in `main.bicep` or pass additional tags during deployment.

## Clean Up

To delete all deployed resources:

```bash
az group delete --name rg-apim-graphql --yes --no-wait
```

## Notes

- API Management provisioning can take 30-45 minutes
- Standard tier provides production-ready features with SLA
- Application Insights integration provides comprehensive monitoring and diagnostics
- System-assigned managed identity is enabled for secure access to other Azure resources

## Next Steps

After deployment:

1. Access the API Management portal using the `apimPortalUrl` output
2. Configure APIs and policies in APIM
3. Monitor API usage and performance in Application Insights
4. Set up additional security features (OAuth, JWT validation, etc.)
