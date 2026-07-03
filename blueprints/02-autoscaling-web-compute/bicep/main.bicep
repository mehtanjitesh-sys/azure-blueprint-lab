targetScope = 'resourceGroup'

param location string = 'eastus'
@minLength(2)
param environment string = 'dev'
@minLength(3)
param resourcePrefix string = 'blueprint-webcompute'
param adminUsername string = 'azureuser'
@secure()
param adminSshPublicKey string

var vnetName = 'vnet-${resourcePrefix}-${environment}'
var lbName = 'lb-${resourcePrefix}-${environment}'
var frontendName = 'public-frontend'
var backendPoolName = 'web-backend'
var probeName = 'http-probe'
var webSubnetName = 'web-subnet'
var cloudInit = base64('#cloud-config\npackage_update: true\npackages:\n  - nginx\nruncmd:\n  - systemctl enable nginx\n  - systemctl start nginx\n  - echo "Azure Blueprint Lab VMSS" > /var/www/html/index.html\n')

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: webSubnetName
        properties: {
          addressPrefix: '10.10.1.0/24'
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-${resourcePrefix}-${environment}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendName
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName
      }
    ]
    probes: [
      {
        name: probeName
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'http-rule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, frontendName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, backendPoolName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, probeName)
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
        }
      }
    ]
  }
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-07-01' = {
  name: 'vmss-${resourcePrefix}-${environment}'
  location: location
  dependsOn: [
    vnet
    lb
  ]
  sku: {
    name: 'Standard_B1s'
    capacity: 2
  }
  properties: {
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'web'
        adminUsername: adminUsername
        customData: cloudInit
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: adminSshPublicKey
              }
            ]
          }
        }
      }
      storageProfile: {
        imageReference: {
          publisher: 'Canonical'
          offer: '0001-com-ubuntu-server-jammy'
          sku: '22_04-lts-gen2'
          version: 'latest'
        }
        osDisk: {
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: 'Standard_LRS'
          }
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic-web'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig'
                  properties: {
                    subnet: {
                      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, webSubnetName)
                    }
                    loadBalancerBackendAddressPools: [
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, backendPoolName)
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}

output publicIpAddress string = publicIp.properties.ipAddress
output vmssName string = vmss.name
