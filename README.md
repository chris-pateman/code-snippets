# Code Snippets

Practical scripts and configuration examples for cloud, platform, automation, and developer tooling.

These snippets are starting points, not production-ready modules. Read the script before running it, replace every environment-specific value, and test changes in a non-production environment first.

## Contents

| Directory | Focus |
| --- | --- |
| `Aws` | AWS command-line and PowerShell helpers |
| `Azure` | Azure CLI, Azure PowerShell, and Resource Graph helpers |
| `Bash` | Bash, certificate, OpenSSL, and command-line utilities |
| `Bat` | Windows batch helpers |
| `Docker` | Dockerfiles and container helpers |
| `Gcp` | Google Cloud command-line and API helpers |
| `PowerShell` | PowerShell automation and administration |
| `SQL` | Database administration snippets |
| `Terraform` | Terraform examples, checks, and modules |

## Safe usage

- Review scripts that create, change, or delete cloud resources before execution.
- Use a least-privilege identity and a dedicated test subscription or project.
- Supply credentials through the cloud CLI, environment variables, a secret manager, or an approved CI secret store.
- Never add passwords, tokens, private keys, certificates, Terraform state, or client data to this repository.
- Treat scripts with names such as `delete`, `purge`, `destroy`, `drop`, or `remove` as destructive until verified.

## Prerequisites

Install only the tools required by the snippet you intend to use. Common dependencies include:

- PowerShell 7+
- Bash, `curl`, and standard Unix utilities
- Azure CLI, AWS CLI, or Google Cloud CLI
- Terraform and provider-specific tooling
- Docker, OpenSSL, SQL tooling, or `ffmpeg` for selected directories

Authentication is intentionally left to the local environment. No credentials are provided by this repository.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for style, testing, and review expectations. Report security issues privately using [SECURITY.md](SECURITY.md).

## License

This project is available under the [MIT License](LICENSE).

## Author

- [PR Code](https://prcode.co.uk)
- [LinkedIn](https://www.linkedin.com/in/christopherpateman)
