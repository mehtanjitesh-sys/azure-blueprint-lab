# IaC Tradeoffs: Bicep And Terraform

This portfolio deliberately implements the same Azure patterns in both Bicep and Terraform.

## Bicep Strengths

- Azure-native resource coverage appears quickly.
- No separate state file is required for basic deployments.
- The syntax maps cleanly to ARM concepts, which helps when reading Azure documentation.
- Good fit for teams that are fully committed to Azure and want simple deployment operations.

## Bicep Costs

- Less useful when a deployment needs to coordinate Azure with GitHub, DNS providers, SaaS tools, or multi-cloud systems.
- Module reuse is strong inside Azure, but less universal across platform boundaries.
- Review workflows often depend more heavily on Azure what-if and deployment history.

## Terraform Strengths

- Consistent workflow across Azure and non-Azure providers.
- `terraform plan` is excellent for pull request review.
- Remote state, locking, modules, and workspaces support team operations.
- Good fit for platform teams that manage many systems from one IaC workflow.

## Terraform Costs

- State must be protected, backed up, locked, and never committed.
- Provider version changes can affect behavior, so pinning and upgrade testing matter.
- Some brand-new Azure features may appear in ARM/Bicep before Terraform provider support lands.

## How I Choose

I would choose Bicep when:

- The platform is Azure-only.
- The team wants minimal tooling.
- The deployment is close to ARM documentation.
- The operational model is simple.

I would choose Terraform when:

- The platform spans Azure plus other providers.
- Pull request plan review is required.
- Remote state and locking are important.
- The team wants reusable modules across many environments.

## Portfolio Interpretation

The goal is not to prove that one tool is always better. The goal is to show that I can separate the architecture from the tool, then explain how each tool changes the engineering workflow.

