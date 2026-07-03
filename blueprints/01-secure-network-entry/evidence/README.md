# Evidence

Add deployment proof here after running the blueprint.

Recommended artifacts:

- `bicep-build-sanitized.md`
- `terraform-validate-sanitized.md`
- `terraform-plan-sanitized.md` or `bicep-what-if-sanitized.md`
- `subnets-sanitized.md` from `az network vnet subnet list`
- `nsg-rules-sanitized.md` from `az network nsg rule list`
- A sanitized Azure Portal topology screenshot

## What I Validated

- [ ] Bicep template builds successfully.
- [ ] Terraform formatting passes.
- [ ] Terraform validates successfully.
- [ ] Network subnets and NSG rules match the architecture.
- [ ] Cleanup command is documented or tested.
