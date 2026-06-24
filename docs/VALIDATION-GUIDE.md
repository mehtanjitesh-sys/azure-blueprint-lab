# Validation Guide

Each blueprint should be reviewed in four passes.

## 1. Static Review

```bash
bicep build bicep/main.bicep
terraform fmt -check
terraform validate
```

## 2. Plan Review

For Bicep:

```bash
az deployment sub what-if \
  --location eastus \
  --template-file bicep/main.bicep \
  --parameters @bicep/parameters.example.json
```

For Terraform:

```bash
terraform init
terraform plan -out=tfplan
```

## 3. Runtime Validation

Use the commands in each blueprint README to confirm the resources exist and behave as expected.

Examples:

- `az network vnet subnet list`
- `az vmss list-instances`
- `az functionapp show`
- `kubectl get nodes`

## 4. Evidence Capture

Add sanitized proof under each blueprint's `evidence/` directory.

Good evidence includes:

- CLI output copied into a text file
- Screenshots with subscription IDs hidden
- Short notes about what was tested
- Cleanup confirmation

## What Not To Commit

- Terraform state
- Kubeconfig files
- Function app local settings
- Secrets
- Subscription IDs, tenant IDs, object IDs, or public IPs unless intentionally anonymized

