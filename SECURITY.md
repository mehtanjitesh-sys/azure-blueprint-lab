# Security Policy

This repository is public and intentionally avoids committing credentials, Terraform state, generated keys, raw deployment evidence, or Azure identifiers from a real environment.

## Do Not Commit

- Real Azure subscription IDs or tenant IDs
- Service principal secrets, certificates, private keys, SAS tokens, storage keys, PATs, or connection strings
- Terraform state files, plan files, `.terraform` folders, or backend credentials
- `terraform.tfvars`, `*.auto.tfvars`, `local.settings.json`, `.env`, or generated publish packages
- Real Entra user, group, service principal, or managed identity object IDs
- Unsanitized screenshots, CLI logs, public IP addresses, or deployment evidence

## Safe To Commit

- Bicep and Terraform source files
- `parameters.example.json` files with placeholder values only
- Documentation, diagrams, and sanitized CLI output
- Security notes that explain tradeoffs without exposing real estate details

## Rules Used Across Blueprints

- Prefer managed identities over stored credentials.
- Keep admin access private where possible.
- Scope network rules to the minimum needed for the demo.
- Store secrets in Key Vault for production-grade variants.
- Use resource group cleanup for lab teardown.
- Review Terraform plans and Bicep what-if output before apply.

## Before Pushing

Run the local safety scan:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-PublicRepoSafety.ps1
```

Review staged changes:

```powershell
git diff --cached
```

## Before Publishing Evidence

Sanitize screenshots and CLI output for:

- Subscription IDs
- Tenant IDs
- Public IP addresses
- Object IDs
- Principal IDs
- Connection strings
- Storage keys
- Access tokens

## If Something Sensitive Was Already Published

1. Rotate or revoke the exposed value immediately.
2. Remove it from the current branch.
3. Treat it as compromised even if the visible file is deleted.
4. Rewrite Git history only after understanding the impact on clones and collaborators.

Deleting a secret in a later commit does not remove it from Git history.
