param name string
param location string = resourceGroup().location
param tags object = {}

param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
param imageName string = 'containerappssecurity/nextapp-sidecar-playground2:azd-deploy-1690537679'
param keyVaultName string
param serviceName string = 'nextapp-sidecar'

module app '../core/host/container-app.bicep' = {
  name: '${serviceName}-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerCpuCoreCount: '0.25'
    containerMemory: '0.5Gi'
    env: [
      {
        name: 'AZURE_KEY_VAULT_ENDPOINT'
        value: keyVault.properties.vaultUri
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }      
      {
        name: 'Logging__ApplicationInsightsKey'
        value: applicationInsights.properties.InstrumentationKey
      }
    ]
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
    keyVaultName: keyVault.name
    targetPort: 3000
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

output SERVICE_NEXtAPI_IDENTITY_PRINCIPAL_ID string = app.outputs.identityPrincipalId
output SERVICE_NEXTAPI_NAME string = app.outputs.name
output SERVICE_NEXTAPI_URI string = app.outputs.uri
output SERVICE_NEXTAPI_IMAGE_NAME string = app.outputs.imageName
output SERVICE_NEXTAPI_DAPR_NAME string = serviceName
