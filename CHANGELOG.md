# Changelog

All notable changes to the CSA Certificate Authority Service demonstration code will be documented in this file.

## [1.1.0] - 2026-06-19

### Added
- Explicit required providers configuration block in `provider.tf` with pinned version ranges for `google` (`>= 4.0.0, < 6.0.0`), `tls` (`>= 4.0.0`), and `time` (`>= 0.9.0`) to ensure build reproducibility.
- Minimum required Terraform version bumped to `>= 1.3.0` for modern syntax compatibility.
- Complete set of type definitions and detailed descriptions for all root-level and child module variable declarations.

### Changed
- Refactored `module-cas/cas.tf` to completely replace fragile and non-portable `local-exec` provisioners. 
- Leaf certificate (`.crt`) and certificate chain (`-chain.crt`) uploads to the Google Cloud Storage bucket are now orchestrated declaratively using native `google_storage_bucket_object` resource parameters.
- Replaced the local shell dependencies (e.g. `gcloud privateca certificates export` and `rm`) with Terraform state properties (`google_privateca_certificate.cert_request.pem_certificate` and `google_privateca_certificate.cert_request.pem_certificate_chain`).
- Streamlined resource dependencies, transitioning from string interpolations to direct reference attributes (e.g., referencing CA Pool names directly via `.name`).

### Fixed
- Fixed an unclosed and misplaced HTML tag in the `README.md` deployment instructions (`cd csa-certificate-authority-service</th>` is now corrected to `cd csa-certificate-authority-service`).
- Standardized file formatting across the workspace using `terraform fmt`.
- Validated workspace configuration structure successfully using `terraform validate`.
