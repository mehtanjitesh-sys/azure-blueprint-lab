# Portfolio Story

Azure Blueprint Lab is a hands-on infrastructure portfolio. It takes common Azure patterns and turns them into repeatable blueprints with both Azure-native and multi-provider IaC workflows.

## The Message To A Reviewer

I can design the architecture first, then express it with the right tool.

For every blueprint I document:

- The architecture
- The resources created
- Cost and cleanup behavior
- Deployment steps
- Validation commands
- Security boundaries
- What I learned
- Bicep vs Terraform tradeoffs

## Interview Talking Points

- I understand that networking decisions shape later security options.
- I avoid direct administrative exposure where possible.
- I treat cost cleanup as part of the lab design.
- I know Terraform state is sensitive operational data.
- I know Bicep is Azure-native and often faster for Azure-only work.
- I know Terraform is useful when the operating model spans providers and teams.
- I validate infrastructure through CLI evidence, not screenshots alone.

