# Public Repo Safety Checklist

This repository is meant to demonstrate Azure infrastructure thinking without exposing a real Azure environment.

## Portfolio Boundary

The repo should show:

- Bicep and Terraform implementation skills
- Architecture tradeoffs
- Validation and cleanup discipline
- Security notes for each blueprint
- Evidence templates using sanitized output

The repo should not show:

- Real subscription IDs or tenant IDs
- Real Entra object IDs
- Real service principal credentials
- Terraform state or plan files
- Storage keys, SAS tokens, connection strings, or local function settings
- Unsanitized screenshots or CLI logs

## Pre-Push Checklist

- `terraform.tfvars`, `*.auto.tfvars`, and `local.settings.json` are not staged.
- No `.tfstate`, `.tfplan`, `.terraform`, key, cert, or package files are staged.
- Evidence screenshots and CLI output are sanitized.
- Parameter files contain placeholder values only.
- No customer, employer, or production naming appears in resource names.
- GitHub Actions uses repository variables/secrets or OIDC, not committed credentials.

## Recommended GitHub Settings

- Enable GitHub secret scanning.
- Enable push protection if available.
- Protect `main`.
- Require the static checks and public repo safety workflow to pass.
- Require pull request review before merge.

## Production-Like Evidence

Use placeholders in committed evidence:

```text
subscriptionId: <subscription-id>
tenantId: <tenant-id>
principalId: <principal-id>
publicIpAddress: <public-ip>
storageAccountKey: <redacted>
```

Keep raw screenshots and command output outside the public repo.
