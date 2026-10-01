# Security Policy

## Reporting a vulnerability

Do not open a public issue for credentials, private information, or other sensitive material.

Report security issues privately through the repository host's security reporting feature. Include the affected path, a short description, and whether a credential should be revoked. Do not include secret values in the report.

## Credential exposure

If a credential is committed accidentally:

1. Revoke or rotate it immediately.
2. Remove it from the working tree and Git history if it was pushed.
3. Check related systems for unauthorized use.
4. Report the incident privately using the process above.

These snippets are examples and are not security-reviewed production components. Review permissions, inputs, dependencies, and side effects before use.
