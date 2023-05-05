@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The name of the service bus namespace.')
param serviceBusName string

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

resource serviceBus'Microsoft.ServiceBus/namespaces@2021-11-01'   existing = {
  name: serviceBusName
}
var serviceBusEndpoint = '${serviceBus.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBusEndpoint, serviceBus.apiVersion).primaryConnectionString
//PubSub service bus Component
resource pubsubComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'pubsub'
  parent: containerAppsEnvironment
  properties: {
    componentType: 'pubsub.azure.servicebus'    
    version: 'v1'
    secrets: [
    ]
    metadata: [
      {
        name: 'connectionString'
        value: serviceBusConnectionString
      }
    ]  
    scopes: [
      'web-backend-api'
      'create-user'
    ]
  }
}
