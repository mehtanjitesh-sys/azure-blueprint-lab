# Azure Blueprint Lab

Portfolio-grade Azure infrastructure projects implemented twice: once with Bicep and once with Terraform.

This repo is designed to show practical Azure understanding, not just syntax. Each blueprint uses the same architecture goal in both tools, then calls out where Bicep and Terraform feel different in day-to-day engineering work.

## Project Catalog

| Label | Blueprint | Azure Skills | Status |
| --- | --- | --- | --- |
| Blueprint 01 | Secure Network Entry Point | VNet, subnets, NSGs, Bastion-ready layout | Drafted |
| Blueprint 02 | Autoscaling Web Compute | VM Scale Sets, load balancing, cloud-init | Drafted |
| Blueprint 03 | Event-Driven Image Pipeline | Storage, Azure Functions, blob events | Drafted |
| Blueprint 04 | Private Container Platform | AKS, ACR, managed identity, node pools | Drafted |

## Repo Pattern

Each blueprint follows the same structure:

```text
blueprints/<number>-<name>/
  README.md
  bicep/
    main.bicep
    parameters.example.json
  terraform/
    main.tf
    variables.tf
    outputs.tf
  evidence/
    README.md
```

## Why Both Bicep And Terraform?

Bicep is the cleanest Azure-native option when the target is Azure only. It maps closely to ARM, supports day-one Azure resources quickly, and avoids external state management for simple deployments.

Terraform is stronger when the team needs a provider-neutral workflow, reusable modules across platforms, remote state, drift detection, and plan output in pull requests. It adds state responsibility, but that responsibility is also what makes team workflows explicit.

This portfolio uses both because the real engineering question is rarely "which syntax is prettier?" It is "which operating model fits the team, platform, and lifecycle?"

## Safety Defaults

- Every blueprint uses a resource group boundary so cleanup is simple.
- Expensive services are marked clearly before deployment.
- No secrets are committed.
- Terraform state files are ignored.
- Each project includes validation and evidence capture steps.

## Suggested Branch And PR Flow

1. Open a feature branch per blueprint.
2. Run `bicep build` and `terraform fmt`.
3. Run `terraform plan` and attach the plan summary to the PR.
4. Deploy only in a sandbox subscription.
5. Add CLI output or screenshots under `evidence/`.
6. Destroy resources after validation.

