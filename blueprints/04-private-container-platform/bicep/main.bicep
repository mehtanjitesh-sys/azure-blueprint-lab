targetScope = 'subscription'

param location string = 'eastus'
param environment string = 'dev'
param resourcePrefix string = 'blueprint-aks'
param uniqueSuffix string = uniqueString(subscription().id, resourcePrefix, environment)

var rgName = 'rg-${resourcePrefix}-${environment}'
var acrName = take(toLower(replace('acr${resourcePrefix}${environment}${uniqueSuffix}', '-', '')), 50)
var aksName = 'aks-${resourcePrefix}-${environment}'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: acrName
  location: location
  scope: rg
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: aksName
  location: location
  scope: rg
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${resourcePrefix}-${environment}'
    agentPoolProfiles: [
      {
        name: 'system'
        count: 1
        vmSize: 'Standard_B2s'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'userpool'
        count: 1
        vmSize: 'Standard_B2s'
        mode: 'User'
        osType: 'Linux'
      }
    ]
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
    }
  }
}

resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, aks.properties.identityProfile.kubeletidentity.objectId, 'AcrPull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

output acrName string = acr.name
output aksName string = aks.name

