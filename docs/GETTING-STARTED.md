# Getting Started

This guide is for someone who has never used this repo before. You can use it to review the code, validate it locally, or deploy a blueprint into a sandbox Azure subscription.

## 1. Install Required Tools

### Git

Install Git:

```powershell
winget install Git.Git
```

Close and reopen PowerShell, then check:

```powershell
git --version
```

### Azure CLI

Install Azure CLI:

```powershell
winget install Microsoft.AzureCLI
```

Close and reopen PowerShell, then check:

```powershell
az version
```

Install Bicep through Azure CLI:

```powershell
az bicep install
az bicep version
```

### Terraform

Install Terraform:

```powershell
winget install Hashicorp.Terraform
```

Close and reopen PowerShell, then check:

```powershell
terraform version
```

## 2. Clone The Repository

Create a simple source-code folder:

```powershell
New-Item -ItemType Directory -Path C:\src -Force
cd C:\src
```

Clone the repo:

```powershell
git clone https://github.com/mehtanjitesh-sys/azure-blueprint-lab.git
cd C:\src\azure-blueprint-lab
```

If you already cloned it, update it:

```powershell
git pull
```

## 3. Run The Public Repo Safety Check

This checks for common mistakes such as state files, local settings, keys, and secret-looking values.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-PublicRepoSafety.ps1
```

Expected result:

```text
Public repo safety scan passed.
```

## 4. Build Every Bicep Template

Run these from the repo root:

```powershell
az bicep build --file .\blueprints\01-secure-network-entry\bicep\main.bicep
az bicep build --file .\blueprints\02-autoscaling-web-compute\bicep\main.bicep
az bicep build --file .\blueprints\03-event-driven-image-pipeline\bicep\main.bicep
az bicep build --file .\blueprints\04-private-container-platform\bicep\main.bicep
```

Generated `main.json` files are ignored by Git.

## 5. Validate Every Terraform Blueprint

Run each folder separately.

```powershell
cd C:\src\azure-blueprint-lab\blueprints\01-secure-network-entry\terraform
terraform init -backend=false
terraform fmt
terraform validate
```

Repeat for:

```powershell
cd C:\src\azure-blueprint-lab\blueprints\02-autoscaling-web-compute\terraform
terraform init -backend=false
terraform fmt
terraform validate
```

```powershell
cd C:\src\azure-blueprint-lab\blueprints\03-event-driven-image-pipeline\terraform
terraform init -backend=false
terraform fmt
terraform validate
```

```powershell
cd C:\src\azure-blueprint-lab\blueprints\04-private-container-platform\terraform
terraform init -backend=false
terraform fmt
terraform validate
```

## 6. Optional: Login To Azure

Only do this if you plan to run `what-if`, `plan`, or deploy resources.

```powershell
az login
az account show --output table
```

Set the correct sandbox subscription:

```powershell
az account set --subscription "<subscription-id-or-name>"
```

Do not use a production subscription for these labs.

## 7. Optional: Run Bicep What-If

Each Bicep blueprint deploys into a resource group. Create the resource group first:

```powershell
az group create --name rg-blueprint-network-dev --location eastus
```

Run what-if:

```powershell
az deployment group what-if `
  --resource-group rg-blueprint-network-dev `
  --template-file .\blueprints\01-secure-network-entry\bicep\main.bicep `
  --parameters @.\blueprints\01-secure-network-entry\bicep\parameters.example.json
```

Use the matching resource group and parameter file for each blueprint.

## 8. Optional: Run Terraform Plan

From a blueprint's `terraform` folder:

```powershell
terraform init
terraform plan
```

Terraform creates local state after apply. Do not commit `.terraform`, `.tfstate`, `.tfplan`, or `terraform.tfvars` files.

## 9. Optional: Deploy And Clean Up

Deploy only in a sandbox subscription.

Bicep deployment example:

```powershell
az deployment group create `
  --resource-group rg-blueprint-network-dev `
  --template-file .\blueprints\01-secure-network-entry\bicep\main.bicep `
  --parameters @.\blueprints\01-secure-network-entry\bicep\parameters.example.json
```

Terraform deployment example:

```powershell
terraform apply
```

Cleanup is mandatory for cost control.

Bicep/resource group cleanup:

```powershell
az group delete --name rg-blueprint-network-dev --yes --no-wait
```

Terraform cleanup:

```powershell
terraform destroy
```

## 10. Evidence For Portfolio Use

After validation, capture sanitized evidence under each blueprint's `evidence/` folder:

- Bicep build passed
- Terraform validate passed
- What-if or plan reviewed
- Screenshot or CLI output with subscription IDs hidden
- Cleanup command documented or tested

Never commit raw output that contains subscription IDs, tenant IDs, object IDs, public IPs, secrets, storage keys, or Terraform state.
