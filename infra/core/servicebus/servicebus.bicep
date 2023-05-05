param location string= ''


// Service Bus namespace 
var servicebusName = 'sb-demo-${uniqueString(resourceGroup().id, 'demo')}'
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: servicebusName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}

  resource topic 'topics' = {
    name: 'createuser'
    properties: {
      supportOrdering: true
    }
  }
}

output name string = serviceBusNamespace.name
