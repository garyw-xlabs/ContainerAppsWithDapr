@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The name of the StorageAccountName.')
param storageAccountName string

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01'   existing = {
  name: storageAccountName
}

//Blobstorage access Component
resource pubsubComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'errorqueueblobstore'
  parent: containerAppsEnvironment
  properties: {
    componentType: 'bindings.azure.blobstorage'    
    version: 'v1'
    secrets: [
    ]
    metadata: [
      {       
        name: 'storageAccount'
        value: storageAccount.name
      }
      {
        name: 'storageAccessKey'
        value: storageAccount.listKeys().keys[0].value
      }
      {
        name:  'container'
        value: 'demo'
      }
      {
        name: 'decodeBase64'
        value: 'false'
      }
      {
        name: 'publicAccessLevel'
        value: 'container'
      }
    ]  
    scopes: [      
      'create-user'
    ]
  }
}
