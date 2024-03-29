targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Optional parameters to override the default azd resource naming conventions. Update the main.parameters.json file to provide values. e.g.,:
// "resourceGroupName": {
//      "value": "myGroupName"
// }
param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param containerAppsEnvironmentName string = ''
param containerRegistryName string = ''
param keyVaultName string = ''
param logAnalyticsName string = ''
param resourceGroupName string = ''
param apiImageName string =''
param otherApiImageName string =''
@description('Id of the user or app to assign application roles')
param principalId string = ''


var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }
var apiContainerAppNameOrDefault = '${abbrs.appContainerApps}web-${resourceToken}'
var corsAcaUrl = 'https://${apiContainerAppNameOrDefault}.${containerApps.outputs.defaultDomain}'

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// Container apps host (including container registry)
module containerApps './core/host/container-apps.bicep' = {
  name: 'container-apps'
  scope: rg
  params: {
    name: 'app'
    containerAppsEnvironmentName: !empty(containerAppsEnvironmentName) ? containerAppsEnvironmentName : '${abbrs.appManagedEnvironments}${resourceToken}'
    containerRegistryName: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
  }
}


// Api backend
module api './app/api.bicep' = {
  name: 'api'
  scope: rg
  params: {
    name: '${abbrs.appContainerApps}api-${resourceToken}'
    location: location
    imageName: apiImageName
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    containerRegistryName: containerApps.outputs.registryName
    keyVaultName: keyVault.outputs.name
  }
}
// Other Api backend
module otherapi './app/otherapi.bicep' = {
  name: 'otherapi'
  scope: rg
  params: {
    name: '${abbrs.appContainerApps}other-api-${resourceToken}'
    location: location
    imageName: otherApiImageName
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    containerRegistryName: containerApps.outputs.registryName
    keyVaultName: keyVault.outputs.name
  }
}
// Next App
// module nextapp './app/nextapp.bicep' = {
//   name: 'nextapp'
//   scope: rg
//   params: {
//     name: '${abbrs.appContainerApps}next-app-${resourceToken}'
//     location: location
//     imageName: nextAppImageName
//     applicationInsightsName: monitoring.outputs.applicationInsightsName
//     containerAppsEnvironmentName: containerApps.outputs.environmentName
//     containerRegistryName: containerApps.outputs.registryName
//     keyVaultName: keyVault.outputs.name
//   }
// }

// Store secrets in a keyvault
module keyVault './core/security/keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
    principalId: principalId
  }
}

// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

module storageAccount './core/storage/storage-account.bicep' ={
  name: 'storageAccount'
  scope: rg
  params: {
   location: location
  }
}

// App outputs
output API_CORS_ACA_URL string = corsAcaUrl
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output APPLICATIONINSIGHTS_NAME string = monitoring.outputs.applicationInsightsName
output AZURE_CONTAINER_ENVIRONMENT_NAME string = containerApps.outputs.environmentName
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerApps.outputs.registryLoginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerApps.outputs.registryName
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output SERVICE_API_IMAGE_NAME  string = api.outputs.SERVICE_API_IMAGE_NAME
output SERVICE_API_NAME string = api.outputs.SERVICE_API_NAME
output SERVICE_API_URI  string = api.outputs.SERVICE_API_URI
output SERVICE_OTHERAPI_IMAGE_NAME  string = otherapi.outputs.SERVICE_OTHERAPI_IMAGE_NAME
output SERVICE_OTHERAPI_NAME string = otherapi.outputs.SERVICE_OTHERAPI_NAME
output SERVICE_OTHERAPI_URI  string = otherapi.outputs.SERVICE_OTHERAPI_URI

// output SERVICE_CREATE_USER_SUB_IMAGE_NAME string = createusersubscriber.outputs.SERVICE_CREATE_USER_SUB_IMAGE_NAME
// output SERVICE_CREATE_USER_SUB_NAME string = createusersubscriber.outputs.SERVICE_CREATE_USER_SUB_NAME
// output SERVICE_CREATE_USER_SUB_URI string = createusersubscriber.outputs.SERVICE_CREATE_USER_SUB_URI
