targetScope = 'subscription'

param location string = 'eastus'
param environment string = 'dev'
param resourcePrefix string = 'blueprint-network'

var rgName = 'rg-${resourcePrefix}-${environment}'
var vnetName = 'vnet-${resourcePrefix}-${environment}'
var webNsgName = 'nsg-${resourcePrefix}-web-${environment}'
var dbNsgName = 'nsg-${resourcePrefix}-db-${environment}'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
}

resource webNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: webNsgName
  location: location
  scope: rg
  properties: {
    securityRules: [
      {
        name: 'AllowHttpHttpsFromInternet'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '80'
            '443'
          ]
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource dbNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: dbNsgName
  location: location
  scope: rg
  properties: {
    securityRules: [
      {
        name: 'AllowMySqlFromWebSubnet'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  scope: rg
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'web-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: webNsg.id
          }
        }
      }
      {
        name: 'db-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: dbNsg.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.3.0/27'
        }
      }
    ]
  }
}

output resourceGroupName string = rg.name
output vnetId string = vnet.id

