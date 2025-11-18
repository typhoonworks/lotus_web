# Changelog

## Unreleased

## [0.6.1] - 2025-11-18

### Internal

- Added a `release` mix task for use with new releases. `release` task ensures assets are always built before publishing.
- Changed tailwind config, removing `--watch=always` in `config.exs`, so that the `assets.build` task can be run without blocking.

### Fixed

- `assets.build` was not run for the 0.6.0 release, breaking the download functionality. 0.6.1 includes the built assets.

## [0.6.0] - 2025-11-14

### Changed

- Implement controller-based query export for chunking exports without creating a local temp file (#34):
  - Unsaved queries can no longer be exported; only saved queries can be exported. This was done to limit the token size in the URL and avoid exposing the data model (as the SQL query would need to be transmitted with the token).

- **INTERNAL:** Comprehensive Credo-based code quality improvements:
  - Added Credo static code analysis tool with custom configuration
  - Eliminated deeply nested functions by extracting helper functions across components
  - Reduced cyclomatic complexity in multiple modules (raised max to 10 for complex validation functions)
  - Improved predicate function naming conventions (e.g., `is_text_type?` → `text_type?`)
  - Refactored complex case statements and conditional logic for better readability
  - Added `@moduledoc false` annotations to internal modules
  - Configured selective exclusions for `MapJoin` warnings where pipe readability is prioritized
  - Enhanced code maintainability and testability without changing public APIs

## [0.5.2] - 2025-09-08

- Allow live view deps up to 1.2

## [0.5.1] - 2025-09-08

- Adds adjustments for mobile browsing

## [0.5.0] - 2025-09-07

### Added

- New `Lotus.Web.Resolver` behavior for customizing user resolution and access control
- **Async Query Execution with LiveView** - Non-blocking query execution using LiveView's async assigns
- **Query Pagination** - Cap rows at 1000 to avoid performance degration
- **Streaming CSV Export** - Memory-efficient CSV export using `Lotus.Export.stream_csv/2`

### Improved

- **Enhanced Flash Message System** - Redesigned flash notifications with improved UX

### Fixed

- Make schema explorer and variable settings asides sticky
- Fix scrolling issues

## [0.4.1] - 2025-09-04

### Fixed

- **UUID Formatting in Dropdown Variables** - Fixed 500 error when using UUIDs in dropdown variable SQL queries
  - Applied `Lotus.Value.to_display_string/1` formatting to query results to properly handle binary UUID data
  - Fixed unreadable HTML entity placeholders in dropdown options modal
  - Improved placeholder text clarity by showing only simple value format

## [0.4.0] - 2025-09-04

### Added

- **Dynamic Variable Options Configuration** - Configure query variable dropdown options from SQL queries
  - New dropdown options modal for configuring variable options with SQL queries
  - Support for fetching and testing variable options dynamically
  - Smart formatting that handles both simple string lists and value/label pairs
  - `VariableOptionsFormatter` module for converting between display and storage formats
  - Enhanced variable settings component with improved options handling
- **Multi-Database Schema Support** - Full support for PostgreSQL schemas and MySQL databases
  - Segmented data source selector with automatic schema detection
  - PostgreSQL search_path support with visual indicator in editor
  - Schema-aware SQL completions and table browsing
  - Persistent schema selection with form state management
- **Light/Dark Mode Theme System** - Complete theming with persistent storage across sessions
- **Global Query Shortcuts** - Query keyboard shortcuts (Cmd+Enter/Ctrl+Enter) now work anywhere on the query editor page, not just when focused in the CodeMirror editor
- **Smart SQL Completions** - Context-aware SQL completions with table and column suggestions
  - Table-aware column suggestions (e.g., typing after `FROM users WHERE` suggests columns from `users` table)
  - Table alias support for qualified column completion
  - Context-sensitive completions for SELECT, WHERE, ORDER BY, GROUP BY, and JOIN clauses
  - Built-in SQL functions and aggregate suggestions
  - Intelligent keyword detection to avoid interfering with SQL keyword completion
  - Dynamic completion theme switching that follows light/dark mode changes
- **Enhanced Query Results UI** - Improved results display with status indicators and actions
  - Results heading always shows when query has been executed
  - Success/Error status badges with appropriate icons and colors
  - Row count and execution time display below status indicators
  - Copy query to clipboard functionality with proper formatting preservation
  - Clipboard button in editor toolbar to copy SQL queries with line breaks preserved
  - CSV export functionality with automatic file downloads

### Changed

- **Improved Table Component** - Removed hardcoded margins from core table component for better flexibility
  - Table margins now controlled by parent containers for consistent spacing
  - Updated all table usages to include appropriate margin wrappers
- **Updated Dependencies** - Enforced Lotus dependency to version 0.9.0
- **Enhanced Copy to Clipboard** - Updated copy to clipboard keyboard shortcut functionality

## [0.3.1] - 2025-09-01

### Added

- **Variables and Widgets System** - Complete support for dynamic SQL queries with `{{variable}}` syntax
  - Variable detection and highlighting in SQL editor with CodeMirror plugin
  - Automatic toolbar widget generation for detected variables
  - Three variable types: Text (auto-quoted), Number, Date (ISO format)
  - Two widget types: Input fields and Dropdown lists with static options
  - Variable settings panel with Help and Settings tabs
  - Variable configurations persist with saved queries (types, widgets, labels, defaults)
  - User input values are not saved - widgets start empty unless defaults are set
- **Enhanced Query Editor Components**
  - Refactored query editor into modular LiveView components
  - New toolbar components for variables and query controls
  - Schema explorer component with improved UX
  - Results component with better formatting
- **New LiveView Components**
  - Theme selector dropdown component with icon-based triggers
  - Date picker component for date variables
  - Select component for dropdown widgets
  - Variable settings component with tabs and configuration options
  - Widget component for rendering different input types
- **Updated Documentation**
  - New Variables and Widgets guide with comprehensive usage examples
  - Updated Getting Started guide with variables section
  - README updated to reflect completed variables feature

### Changed
- Enhanced Tailwind CSS configuration with dark mode support and custom color palette
- Updated all UI components with comprehensive dark mode variants
- Improved CodeMirror editor styling for both light and dark themes
- Upgraded to Lotus v0.5.4 for enhanced variable support
- Improved aside panel toggling UX and scrolling behavior
- Enhanced JavaScript editor integration with variables plugin
- Auto-run queries now check for missing variables before execution using `Lotus.can_run?`

## [0.1.4] - 2025-08-25

- Upgrade to Lotus v0.3.3
- Improved cell formatting for HTML display

## [0.1.2] - 2025-08-25

Quick hotfix to safely format cell values for HTML display

## [0.1.1] - 2025-08-25

Add `priv/static` to package files

## [0.1.0] - 2025-08-25
- Initial release
