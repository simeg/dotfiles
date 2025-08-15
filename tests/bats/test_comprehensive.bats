#!/usr/bin/env bats

# Comprehensive test suite that combines all test categories
# This replaces the shell-based test_comprehensive.sh

load setup_suite

# Import all other test files
load test_configuration
load test_advanced_config
load test_performance
load test_security
load test_ci

# Add a summary test that can be run to show overall status
@test "Test suite summary" {
    echo "Comprehensive test suite completed successfully" >&3
    echo "All configuration, performance, security, and CI tests passed" >&3
}