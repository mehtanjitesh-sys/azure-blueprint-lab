# Security Notes

This portfolio intentionally avoids committing credentials, state files, generated keys, or deployment outputs that may contain secrets.

## Rules Used Across Blueprints

- Prefer managed identities over stored credentials.
- Keep admin access private where possible.
- Scope network rules to the minimum needed for the demo.
- Store secrets in Key Vault for production-grade variants.
- Use resource group cleanup for lab teardown.
- Review Terraform plans and Bicep what-if output before apply.

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

