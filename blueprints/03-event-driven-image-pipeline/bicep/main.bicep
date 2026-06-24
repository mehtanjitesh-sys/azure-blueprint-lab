targetScope = 'subscription'

param location string = 'eastus'
param environment string = 'dev'
param resourcePrefix string = 'blueprint-imagepipe'
param uniqueSuffix string = uniqueString(subscription().id, resourcePrefix, environment)

var rgName = 'rg-${resourcePrefix}-${environment}'
var storageName = toLower(replace('st${resourcePrefix}${environment}${uniqueSuffix}', '-', ''))
var appName = 'func-${resourcePrefix}-${environment}-${uniqueSuffix}'
var planName = 'plan-${resourcePrefix}-${environment}'
var insightsName = 'appi-${resourcePrefix}-${environment}'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
}

resource storage 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: take(storageName, 24)
  location: location
  scope: rg
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  name: 'default'
  parent: storage
}

resource uploads 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  name: 'uploads'
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

resource thumbnails 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  name: 'thumbnails'
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

resource insights 'Microsoft.Insights/components@2020-02-02' = {
  name: insightsName
  location: location
  scope: rg
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  scope: rg
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: appName
  location: location
  scope: rg
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'Python|3.11'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: insights.properties.InstrumentationKey
        }
      ]
    }
    httpsOnly: true
  }
}

output storageAccountName string = storage.name
output functionAppName string = functionApp.name

