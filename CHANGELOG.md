# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-14

### Changed
- **BREAKING**: Migrated from deprecated `honeycombio_board` to `honeycombio_flexible_board` resource
- Updated board resource declaration to use new panel-based configuration
- Board queries and functionality remain unchanged

### Migration Notes

Users upgrading from v0.0.3 to v0.1.0 will need to handle Terraform state migration.

**Option 1: Allow Terraform to Replace (Recommended)**
```bash
terraform plan  # Review the replacement
terraform apply # Apply the changes
```
- Board URL will change, existing bookmarks will break
- No data loss; queries are preserved

**Option 2: Manual State Migration**
```bash
terraform state mv 'honeycombio_board.confluent_kafka' 'honeycombio_flexible_board.confluent_kafka'
terraform plan  # Verify no changes needed
```
- Preserves existing board and URL
- Requires manual intervention

## [0.0.3] - Previous Release

Initial releases without changelog tracking.
