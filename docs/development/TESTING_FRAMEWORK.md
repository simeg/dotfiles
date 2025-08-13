# 🧪 Advanced Testing Framework

The dotfiles repository includes a comprehensive testing framework that ensures configuration integrity, monitors performance, and validates security compliance. This document provides detailed information about the testing system architecture, usage, and extension.

## Table of Contents

- [Overview](#overview)
- [Testing Architecture](#testing-architecture)
- [Test Categories](#test-categories)
- [Usage Guide](#usage-guide)
- [CI/CD Integration](#cicd-integration)
- [Performance Monitoring](#performance-monitoring)
- [Security Compliance](#security-compliance)
- [Extending the Framework](#extending-the-framework)
- [Troubleshooting](#troubleshooting)

## Overview

The advanced testing framework provides three layers of validation:

1. **Basic Tests**: Core functionality and syntax validation
2. **CI Tests**: Automated testing for continuous integration
3. **Advanced Tests**: Configuration validation, performance regression, and security compliance

### Key Features

- 🔧 **Configuration Validation**: Validates syntax, structure, and completeness
- ⚡ **Performance Regression Testing**: Monitors performance with baseline tracking
- 🔒 **Security Compliance**: Scans for vulnerabilities and security misconfigurations
- 🚀 **Comprehensive Coverage**: Tests all aspects of the dotfiles setup
- 📊 **Detailed Reporting**: Provides actionable insights and recommendations
- 🔄 **CI Integration**: Seamlessly integrates with existing CI/CD pipelines

## Testing Architecture

### Test Scripts Organization

```
scripts/tests/
├── test_dotfiles.sh         # Basic functionality tests
├── test_ci.sh               # CI-specific tests (no dependencies)
├── test_advanced.sh         # Advanced validation framework
└── test_comprehensive.sh    # Test orchestrator and runner
```

### Test Flow Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Basic Tests   │───▶│   CI Tests      │───▶│ Advanced Tests  │
│                 │    │                 │    │                 │
│ • Syntax        │    │ • Structure     │    │ • Config Valid  │
│ • Dependencies  │    │ • File Exists   │    │ • Performance   │
│ • Symlinks      │    │ • Syntax Check  │    │ • Security      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                    ┌─────────────────────────┐
                    │ Comprehensive Report    │
                    │                         │
                    │ • Test Results Summary  │
                    │ • Performance Metrics  │
                    │ • Security Findings    │
                    │ • Recommendations      │
                    └─────────────────────────┘
```

## Test Categories

### 1. Basic Tests (`test_dotfiles.sh`)

**Purpose**: Validate core dotfiles functionality and dependencies

**Tests Included**:
- Zsh syntax validation
- Modular configuration existence and syntax
- Essential command availability
- Plugin configuration
- Starship prompt setup
- Neovim configuration
- Git configuration
- PATH configuration
- Shell startup performance

**Usage**:
```bash
# Run all basic tests
./scripts/tests/test_dotfiles.sh

# Run syntax tests only
./scripts/tests/test_dotfiles.sh --syntax-only

# Run performance tests only
./scripts/tests/test_dotfiles.sh --perf-only

# Quick essential tests
./scripts/tests/test_dotfiles.sh --quick
```

### 2. CI Tests (`test_ci.sh`)

**Purpose**: CI-friendly tests that don't require local installation

**Tests Included**:
- Source file syntax validation
- Directory structure verification
- Essential file existence
- Brewfile syntax validation
- Shell script syntax validation

**Usage**:
```bash
# Run CI tests
./scripts/tests/test_ci.sh
```

### 3. Advanced Tests (`test_advanced.sh`)

**Purpose**: Comprehensive validation including configuration, performance, and security

#### Configuration Validation

**Zsh Configuration**:
- Validates modular structure
- Checks that .zshrc sources all modules
- Detects dangerous alias redefinitions
- Verifies configuration completeness

**Neovim Configuration**:
- Validates directory structure
- Checks for required files
- Verifies Lua configuration presence

**Git Configuration**:
- Validates required settings
- Scans for hardcoded credentials
- Checks .gitignore effectiveness
- Verifies security configurations

**Starship Configuration**:
- Validates TOML syntax
- Checks theme file structure
- Verifies configuration completeness

**Package Management**:
- Validates Brewfile syntax
- Checks for essential packages
- Detects potential conflicts

#### Performance Regression Testing

**Shell Startup Performance**:
- Measures current startup time (average of 5 runs)
- Compares against baseline
- Detects performance regressions (>30% increase)
- Creates new baselines when needed

**Memory Usage Monitoring**:
- Tracks memory consumption
- Compares against historical baselines
- Alerts on significant increases (>50%)

**Plugin Performance**:
- Analyzes plugin load times
- Identifies slow-loading plugins
- Provides optimization recommendations

#### Security Compliance Checks

**Secrets Scanning**:
- Intelligent pattern matching for credentials
- Context-aware validation (avoids false positives)
- Scans configuration files for exposed secrets

**File Permissions**:
- Validates secure file permissions
- Checks for world-writable files
- Ensures executable scripts have proper permissions

**Shell Security**:
- Validates secure PATH configuration
- Checks umask settings
- Verifies history file security

**Git Security**:
- Validates secure URL protocols
- Checks credential helper configuration
- Verifies GPG signing setup

**Dependency Security**:
- Analyzes Homebrew tap sources
- Validates secure download protocols
- Checks for suspicious dependencies

## Usage Guide

### Make Targets

The testing framework integrates with the Makefile for easy access:

```bash
# Quick validation (recommended for development)
make test-quick

# Pre-commit validation
make test-precommit

# Full comprehensive test suite
make test

# Advanced tests only
make test-advanced

# CI tests
make test-ci
```

### Direct Script Usage

#### Comprehensive Test Runner

```bash
# Run full test suite
./scripts/tests/test_comprehensive.sh full

# Quick validation tests
./scripts/tests/test_comprehensive.sh quick

# Pre-commit tests
./scripts/tests/test_comprehensive.sh precommit

# Generate test report
./scripts/tests/test_comprehensive.sh report ~/test-report.txt
```

#### Advanced Tests

```bash
# Run all advanced tests
./scripts/tests/test_advanced.sh all

# Configuration validation only
./scripts/tests/test_advanced.sh config

# Performance regression tests
./scripts/tests/test_advanced.sh performance

# Security compliance checks
./scripts/tests/test_advanced.sh security

# Create performance baseline
./scripts/tests/test_advanced.sh baseline
```

### Test Output Interpretation

#### Success Output
```
🧪 Running Test Suite: Configuration Validation
[PASS] Zsh Configuration Validation
[PASS] Neovim Configuration Validation
[PASS] Git Configuration Validation
✅ Configuration Validation completed successfully
```

#### Warning Output
```
[WARN] Git commit signing not configured (recommended for security)
Note: 1 warnings were found - consider addressing them.
```

#### Failure Output
```
[FAIL] Zsh Configuration Validation
Missing required Zsh config: functions.zsh
❌ Configuration Validation failed
```

## CI/CD Integration

### GitHub Actions Integration

The testing framework integrates with existing GitHub Actions workflows:

```yaml
# .github/workflows/test.yml
- name: Run Advanced Tests
  run: |
    make test-advanced
    
- name: Generate Test Report
  run: |
    ./scripts/tests/test_comprehensive.sh report test-results.txt
    
- name: Upload Test Results
  uses: actions/upload-artifact@v3
  with:
    name: test-results
    path: test-results.txt
```

### Pre-commit Hooks

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: dotfiles-tests
        name: Dotfiles Pre-commit Tests
        entry: make test-precommit
        language: system
        pass_filenames: false
```

## Performance Monitoring

### Baseline Management

Performance baselines are stored in `~/.config/dotfiles/perf-baseline.json`:

```json
{
  "shell_startup_ms": 450,
  "memory_usage_kb": 15000,
  "created": "2024-01-15T10:30:00Z"
}
```

### Creating Baselines

```bash
# Create initial performance baseline
./scripts/tests/test_advanced.sh baseline

# Update baseline after optimizations
./scripts/tests/test_advanced.sh performance
```

### Performance Thresholds

- **Shell Startup**: Alert if >30% slower than baseline
- **Memory Usage**: Alert if >50% higher than baseline
- **Plugin Load**: Alert if individual plugins >200ms

### Performance Optimization Workflow

1. **Baseline Creation**: `make test-advanced` (creates baseline on first run)
2. **Regular Monitoring**: Run tests weekly with `make test-advanced`
3. **Regression Detection**: Tests fail if performance degrades significantly
4. **Optimization**: Use recommendations from test output
5. **Validation**: Re-run tests to confirm improvements

## Security Compliance

### Security Baseline

Security baselines track configuration state in `~/.config/dotfiles/security-baseline.json`:

```json
{
  "created": "2024-01-15T10:30:00Z",
  "file_count": 45,
  "script_count": 12,
  "config_files": 18
}
```

### Security Scanning Patterns

The framework scans for these security patterns:

**High Risk**:
- Hardcoded passwords: `password=`
- API tokens: `token=`, `api_key=`
- SSH keys: `BEGIN PRIVATE KEY`

**Medium Risk**:
- Insecure protocols: `http://`
- World-writable files: `chmod 777`
- Dangerous PATH: `PATH=.:$PATH`

**Low Risk (Warnings)**:
- Missing GPG signing
- Unofficial Homebrew taps
- Missing credential helpers

### False Positive Reduction

The scanner includes intelligent filtering:

```bash
# These patterns are excluded as safe:
# Comments: "# This password is fake"
# Test code: "grep password"
# Log messages: "echo 'checking password'"
# String literals: "'password' in text"
```

## Extending the Framework

### Adding New Test Categories

1. **Create Test Function**:
```bash
# In test_advanced.sh
test_my_new_validation() {
    local issues=0
    
    # Add your validation logic here
    if [[ condition_fails ]]; then
        echo "Validation failed: reason"
        issues=$((issues + 1))
    fi
    
    return $issues
}
```

2. **Add to Test Runner**:
```bash
# In appropriate test runner function
run_test "My New Validation" test_my_new_validation
```

3. **Update Documentation**: Add details to this file

### Adding Custom Security Patterns

```bash
# Add to test_security_secrets_scan()
local custom_patterns=("myapp_secret" "private_key" "auth_token")
secret_patterns+=("${custom_patterns[@]}")
```

### Creating Project-Specific Tests

Create a new test script following the framework pattern:

```bash
#!/usr/bin/env bash
# scripts/tests/test_project_specific.sh

# Source the framework functions
source "$(dirname "${BASH_SOURCE[0]}")/test_advanced.sh"

test_project_specific_config() {
    # Your project-specific tests
    return 0
}

main() {
    run_test "Project Specific Config" test_project_specific_config
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Troubleshooting

### Common Issues

#### Test Dependencies Missing

**Issue**: `bc (calculator) is required for performance tests`

**Solution**:
```bash
# macOS
brew install bc

# Linux
sudo apt-get install bc
```

#### Performance Baseline Issues

**Issue**: `No performance baseline found`

**Solution**:
```bash
# Create new baseline
./scripts/tests/test_advanced.sh baseline

# Or run performance tests to auto-create
./scripts/tests/test_advanced.sh performance
```

#### False Positive Security Alerts

**Issue**: Security scanner flagging safe patterns

**Solution**: Update the exclusion patterns in `test_security_secrets_scan()`:

```bash
# Add to safe patterns
if ! grep -iE "(export.*=|alias.*=|#.*$pattern|grep.*$pattern|your_safe_pattern)" "$file"
```

#### Lua Validation Errors

**Issue**: Neovim Lua configs failing validation

**Solution**: The framework skips Neovim-specific Lua validation by design. If getting false failures, ensure the detection logic is working:

```bash
# Check if file contains Neovim-specific code
grep -q "vim\." "$lua_file" && echo "Neovim-specific (skipped)"
```

### Test Performance Issues

#### Slow Test Execution

**Symptoms**: Tests taking >30 seconds to complete

**Solutions**:
1. Use `make test-quick` for development
2. Run individual categories: `./scripts/tests/test_advanced.sh config`
3. Skip intensive checks in development mode

#### Memory Usage During Tests

**Symptoms**: High memory consumption during test runs

**Solutions**:
1. Run tests individually rather than full suite
2. Clear shell history before performance tests
3. Close other applications during testing

### Debugging Test Failures

#### Enable Verbose Output

```bash
# Add debug output to tests
set -x  # Enable bash debugging
```

#### Manual Test Execution

```bash
# Run individual test functions
source ./scripts/tests/test_advanced.sh
test_zsh_config_validation
echo "Exit code: $?"
```

#### Check Test Dependencies

```bash
# Verify all required tools are available
./scripts/tests/test_comprehensive.sh
# Look for "Missing required dependencies" warnings
```

## Best Practices

### Development Workflow

1. **Pre-commit**: Always run `make test-precommit` before committing
2. **Regular Testing**: Run `make test-quick` during development
3. **Full Validation**: Run `make test` before major changes
4. **Performance Monitoring**: Run advanced tests weekly

### CI/CD Integration

1. **Fast Feedback**: Use `test-ci` for quick PR validation
2. **Comprehensive Testing**: Use full test suite for main branch
3. **Performance Tracking**: Store and compare baselines over time
4. **Security Scanning**: Include security tests in all CI runs

### Maintenance

1. **Baseline Updates**: Refresh performance baselines after optimizations
2. **Pattern Updates**: Update security patterns for new threats
3. **Test Coverage**: Add tests for new configuration areas
4. **Documentation**: Keep this documentation updated with changes

## Integration with Existing Features

### Analytics Integration

The testing framework integrates with the existing analytics system:

- Performance data feeds into analytics dashboard
- Test results can be tracked over time
- Optimization suggestions align with analytics insights

### Health Check Integration

Advanced tests complement the existing health check system:

- Basic health checks validate installation
- Advanced tests validate configuration quality
- Both systems provide comprehensive validation

### Make Target Integration

All testing functions are available through Make targets:

- Consistent interface with other dotfiles operations
- Easy integration with development workflows
- Documented in `docs/MAKE_TARGETS.md`

---

**Related Documentation**:
- [Analytics & Performance Monitoring](ANALYTICS_MONITORING.md)
- [Make Targets](../MAKE_TARGETS.md)
- [Automation & Setup](AUTOMATION_SETUP.md)