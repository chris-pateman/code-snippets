# Contributing

Thanks for helping improve the snippets.

## Before opening a pull request

- Read the complete script and test it in a disposable environment.
- Remove personal, client, subscription, tenant, host, and environment-specific values.
- Never commit passwords, tokens, private keys, certificates, Terraform state, or `.tfvars` files.
- Add usage information and prerequisites when adding a new snippet.
- Keep changes focused and explain any destructive behavior in the pull request.

## Style

- Use approved PowerShell verbs and comment-based help for reusable PowerShell scripts.
- Quote shell variables and use strict-mode or equivalent safety settings where practical.
- Prefer parameters and environment variables over hard-coded values.
- Use descriptive, consistent file names.
- Do not commit generated output, downloaded binaries, or local configuration.

## Validation

Run the relevant checks locally before submitting:

- PowerShell syntax and PSScriptAnalyzer checks
- `shellcheck` for shell scripts
- `terraform fmt` and `terraform validate` for Terraform changes
- JSON, YAML, and Markdown validation where applicable
- A secret scan over the complete working tree

Pull requests may be rejected if they contain credentials, private information, or unreviewed destructive behavior.
