# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Added

- Initial RDS PostgreSQL module for managed instances, allowlists, accounts,
  databases, parameter templates, and explicit backups.
- Basic and complete examples for PostgreSQL 14.
- Sensitive endpoint and account-password handling.

### Fixed

- Normalized empty account privilege exclusions to avoid a perpetual plan
  difference with Provider `0.0.70`.

### Deferred

- Provider `0.0.70` cannot bind a PostgreSQL parameter template to an
  instance.
- The RDS PostgreSQL API does not support deleting Physical backups; their
  retention policy controls cleanup.
