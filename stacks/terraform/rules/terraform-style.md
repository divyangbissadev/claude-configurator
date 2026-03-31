# Terraform Style Rules

## File Organization
- `main.tf` — primary resource definitions
- `variables.tf` — all input variables
- `outputs.tf` — all output values
- `versions.tf` — required providers and Terraform version
- `locals.tf` — computed local values
- `data.tf` — data sources (when there are many)
- `provider.tf` — provider configuration (in root modules)

## Naming Conventions
- Resources and data sources: `snake_case` (e.g., `aws_instance.web_server`)
- Variables: `snake_case` with descriptive names (e.g., `vpc_cidr_block`)
- Outputs: `snake_case` matching the value they expose (e.g., `instance_id`)
- Locals: `snake_case` (e.g., `common_tags`)
- Modules: `kebab-case` for directory names (e.g., `modules/vpc-network/`)

## Formatting
- Run `terraform fmt` before every commit
- One blank line between resource blocks
- Group related arguments within a block (required first, optional second)
- Use `#` comments for inline explanations, `//` is not valid in HCL

## Variables
- Always include `description` for every variable
- Always include `type` constraint
- Use `validation` blocks for input validation with clear error messages
- Order: `description`, `type`, `default`, `validation`, `sensitive`, `nullable`
- Group related variables together with comment headers

## Resources
- Use `for_each` over `count` for conditional or dynamic resources
- Use `lifecycle` blocks explicitly when needed (prevent_destroy, ignore_changes)
- Put `tags` as the last argument in resource blocks
- Use `depends_on` sparingly — prefer implicit dependencies via references
