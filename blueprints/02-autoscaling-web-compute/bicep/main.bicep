targetScope = 'subscription'

param location string = 'eastus'
param environment string = 'dev'
param resourcePrefix string = 'blueprint-webcompute'
param adminUsername string = 'azureuser'
@secure()
param adminSshPublicKey string

var rgName = 'rg-${resourcePrefix}-${environment}'
var cloudInit = base64('#cloud-config\npackage_update: true\npackages:\n  - nginx\nruncmd:\n  - systemctl enable nginx\n  - systemctl start nginx\n  - echo "Azure Blueprint Lab VMSS" > /var/www/html/index.html\n')

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-${resourcePrefix}-${environment}'
  location: location
  scope: rg
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'web-subnet'
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
  scope: rg
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: 'lb-${resourcePrefix}-${environment}'
  location: location
  scope: rg
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'public-frontend'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'web-backend'
      }
    ]
    probes: [
      {
        name: 'http-probe'
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
            id: resourceId(rg.name, 'Microsoft.Network/loadBalancers/frontendIPConfigurations', lb.name, 'public-frontend')
          }
          backendAddressPool: {
            id: resourceId(rg.name, 'Microsoft.Network/loadBalancers/backendAddressPools', lb.name, 'web-backend')
          }
          probe: {
            id: resourceId(rg.name, 'Microsoft.Network/loadBalancers/probes', lb.name, 'http-probe')
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
  scope: rg
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
                      id: vnet.properties.subnets[0].id
                    }
                    loadBalancerBackendAddressPools: [
                      {
                        id: resourceId(rg.name, 'Microsoft.Network/loadBalancers/backendAddressPools', lb.name, 'web-backend')
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

