targetScope = 'resourceGroup'

param location string = 'eastus'
@minLength(2)
@maxLength(7)
param environment string = 'dev'
@minLength(3)
@maxLength(27)
param resourcePrefix string = 'blueprint-aks'
@minLength(6)
@maxLength(13)
param uniqueSuffix string = uniqueString(resourceGroup().id, resourcePrefix, environment)

var acrName = toLower(replace('acr${resourcePrefix}${environment}${uniqueSuffix}', '-', ''))
var aksName = 'aks-${resourcePrefix}-${environment}'
var acrPullRoleDefinitionId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: acrName
  location: location
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
  name: guid(acr.id, aksName, acrPullRoleDefinitionId)
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionId)
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

output acrName string = acr.name
output aksName string = aks.name
