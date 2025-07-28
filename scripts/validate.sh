#!/usr/bin/env bash

# Configuration validation script for dotfiles
# Checks that all symlinks exist and configurations are working properly

# Note: Not using 'set -e' here since we want to continue validation even if some checks fail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASSED_CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
    ((WARNING_CHECKS++))
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAILED_CHECKS++))
}

# Increment total checks counter
check() {
    ((TOTAL_CHECKS++))
}

# Check if a symlink exists and points to the correct target
check_symlink() {
    local link_path="$1"
    local expected_target="$2"
    local description="$3"

    check

    if [[ ! -L "$link_path" ]]; then
        log_error "$description: Symlink $link_path does not exist"
        return 1
    fi

    local actual_target
    actual_target=$(readlink "$link_path")

    if [[ "$actual_target" != "$expected_target" ]]; then
        log_error "$description: Symlink $link_path points to '$actual_target', expected '$expected_target'"
        return 1
    fi

    log_success "$description: Symlink $link_path correctly points to $expected_target"
    return 0
}

# Check if a file exists
check_file_exists() {
    local file_path="$1"
    local description="$2"

    check

    if [[ -f "$file_path" ]]; then
        log_success "$description: File $file_path exists"
        return 0
    else
        log_error "$description: File $file_path does not exist"
        return 1
    fi
}

# Check if a directory exists
check_directory_exists() {
    local dir_path="$1"
    local description="$2"

    check

    if [[ -d "$dir_path" ]]; then
        log_success "$description: Directory $dir_path exists"
        return 0
    else
        log_error "$description: Directory $dir_path does not exist"
        return 1
    fi
}

# Check if a command is available
check_command() {
    local command_name="$1"
    local description="$2"

    check

    if command -v "$command_name" >/dev/null 2>&1; then
        local version
        case "$command_name" in
            git)
                version=$(git --version)
                ;;
            brew)
                version=$(brew --version | head -1)
                ;;
            zsh)
                version=$(zsh --version)
                ;;
            *)
                version="Available"
                ;;
        esac
        log_success "$description: $command_name is available ($version)"
        return 0
    else
        log_error "$description: $command_name command not found"
        return 1
    fi
}

# Check Zsh configuration
check_zsh_config() {
    log_info "Checking Zsh configuration..."

    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"

    # Check main zsh files
    check_symlink "$HOME/.zshrc" "$dotfiles_dir/zsh/.zshrc" "Zsh main config"
    check_symlink "$HOME/.znap-plugins.zsh" "$dotfiles_dir/zsh/.znap-plugins.zsh" "Zsh plugins config"

    # Check if znap is installed
    check_directory_exists "$HOME/.znap" "Znap plugin manager"

    # Check if starship config exists (managed by starship-theme tool)
    check_file_exists "$HOME/.config/starship.toml" "Starship config"

    # Check if zsh is the default shell
    check
    if [[ "$SHELL" == *"zsh"* ]]; then
        log_success "Default shell: Zsh is set as default shell"
    else
        log_warning "Default shell: Current shell is $SHELL, not Zsh"
    fi
}

# Check Git configuration
check_git_config() {
    log_info "Checking Git configuration..."

    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"

    # Check git config files
    check_symlink "$HOME/.gitconfig" "$dotfiles_dir/git/.gitconfig" "Git config"
    check_symlink "$HOME/.gitignore" "$dotfiles_dir/git/.gitignore" "Git global ignore"

    # Check git configuration values
    check
    local git_name
    git_name=$(git config --global user.name 2>/dev/null || echo "")
    if [[ -n "$git_name" ]]; then
        log_success "Git user name: '$git_name' is configured"
    else
        log_warning "Git user name: Not configured"
    fi

    check
    local git_email
    git_email=$(git config --global user.email 2>/dev/null || echo "")
    if [[ -n "$git_email" ]]; then
        log_success "Git user email: '$git_email' is configured"
    else
        log_warning "Git user email: Not configured"
    fi
}

# Check Vim configuration
check_vim_config() {
    log_info "Checking Vim configuration..."

    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"

    # Check ideavim config
    check_symlink "$HOME/.ideavimrc" "$dotfiles_dir/nvim/.ideavimrc" "IdeaVim config"
}

# Check Homebrew and packages
check_homebrew() {
    log_info "Checking Homebrew..."

    # Check if brew is installed
    check_command "brew" "Homebrew"

    if command -v brew >/dev/null 2>&1; then
        # Check if Brewfile exists and packages are installed
        local dotfiles_dir
        dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"

        if [[ -f "$dotfiles_dir/install/Brewfile" ]]; then
            check
            if brew bundle check --file="$dotfiles_dir/install/Brewfile" >/dev/null 2>&1; then
                log_success "Homebrew packages: All Brewfile packages are installed"
            else
                log_warning "Homebrew packages: Some Brewfile packages may be missing"
            fi
        fi

        # Check for common packages
        local common_packages=("git" "zsh")
        for package in "${common_packages[@]}"; do
            check_command "$package" "Package: $package"
        done
    fi
}

# Check bin directory
check_bin_directory() {
    log_info "Checking bin directory..."

    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"

    # Check bin symlink
    check_symlink "$HOME/.bin" "$dotfiles_dir/scripts/bin" "Bin directory"

    # Check if bin is in PATH
    check
    if [[ ":$PATH:" == *":$HOME/.bin:"* ]]; then
        log_success "PATH: ~/.bin is in PATH"
    else
        log_warning "PATH: ~/.bin is not in PATH"
    fi

    # Check if bin scripts are executable
    if [[ -d "$dotfiles_dir/scripts/bin" ]]; then
        local non_executable=()
        while IFS= read -r -d '' file; do
            if [[ ! -x "$file" ]]; then
                non_executable+=("$(basename "$file")")
            fi
        done < <(find "$dotfiles_dir/scripts/bin" -type f -print0)

        check
        if [[ ${#non_executable[@]} -eq 0 ]]; then
            log_success "Bin scripts: All scripts are executable"
        else
            log_warning "Bin scripts: Non-executable scripts: ${non_executable[*]}"
        fi
    fi
}

# Check modular configuration
check_modular_config() {
    log_info "Checking modular configuration..."
    
    local config_dir="$HOME/.config/zsh"
    local configs=("aliases.zsh" "exports.zsh" "functions.zsh" "misc.zsh" "path.zsh")
    
    # Check if modular config directory exists
    check_directory_exists "$config_dir" "Modular config directory"
    
    # Check each config file
    for config in "${configs[@]}"; do
        local config_file="$config_dir/$config"
        check_file_exists "$config_file" "Modular config: $config"
        
        # Syntax check
        if [[ -f "$config_file" ]]; then
            check
            if zsh -n "$config_file" 2>/dev/null; then
                log_success "Syntax check: $config is valid"
            else
                log_error "Syntax check: $config has syntax errors"
            fi
        fi
    done
    
    # Check private config handling
    check
    local private_config="$config_dir/private.zsh"
    if grep -q "private.zsh" "$HOME/.zshrc"; then
        log_success "Private config: .zshrc sources private.zsh"
        
        if [[ -f "$private_config" ]]; then
            if zsh -n "$private_config" 2>/dev/null; then
                log_success "Private config: private.zsh syntax is valid"
            else
                log_error "Private config: private.zsh has syntax errors"
            fi
        else
            log_warning "Private config: private.zsh not found (create for sensitive vars)"
        fi
    else
        log_error "Private config: .zshrc doesn't source private.zsh"
    fi
    
    # Check .gitignore for private files
    check
    local gitignore_file="$config_dir/.gitignore"
    if [[ -f "$gitignore_file" ]] && grep -q "private.zsh" "$gitignore_file"; then
        log_success "Security: .gitignore excludes private files"
    else
        log_warning "Security: No .gitignore for private configs"
    fi
}

# Check shell performance
check_shell_performance() {
    log_info "Checking shell performance..."
    
    # Measure shell startup time
    check
    local startup_times=()
    for _ in {1..3}; do
        local time_output
        time_output=$(time (zsh -c 'exit') 2>&1 | grep real | awk '{print $2}')
        startup_times+=("$time_output")
    done
    
    log_info "Shell startup times: ${startup_times[*]}"
    
    # Check if startup is reasonable (average under 1.5 seconds)
    local total_seconds=0
    local count=0
    for time_str in "${startup_times[@]}"; do
        if [[ "$time_str" =~ ([0-9]+)\.([0-9]+)s ]]; then
            local seconds=${BASH_REMATCH[1]}
            local decimals=${BASH_REMATCH[2]}
            # Convert to milliseconds for easier math
            local ms=$((seconds * 1000 + 10#$decimals * 10))
            total_seconds=$((total_seconds + ms))
            count=$((count + 1))
        fi
    done
    
    if [[ $count -gt 0 ]]; then
        local avg_ms=$((total_seconds / count))
        # avg_seconds calculation removed - was unused
        if [[ $avg_ms -lt 1500 ]]; then
            log_success "Performance: Shell startup is fast (avg: ${avg_ms}ms)"
        elif [[ $avg_ms -lt 3000 ]]; then
            log_warning "Performance: Shell startup is moderate (avg: ${avg_ms}ms)"
        else
            log_error "Performance: Shell startup is slow (avg: ${avg_ms}ms)"
        fi
    fi
}

# Check shell functionality
check_shell_functionality() {
    log_info "Checking shell functionality..."

    # Check if starship is working
    check
    if command -v starship >/dev/null 2>&1; then
        if starship print-config &>/dev/null; then
            log_success "Starship prompt: Available and configured"
        else
            log_warning "Starship prompt: Available but config may be invalid"
        fi
    else
        log_warning "Starship prompt: Not found"
    fi

    # Check if zsh plugins are loaded (in a new zsh session)
    check
    if zsh -c 'autoload -U compinit && compinit -C && echo "Completions working"' >/dev/null 2>&1; then
        log_success "Zsh completions: Working"
    else
        log_warning "Zsh completions: May not be working properly"
    fi
    
    # Check znap plugin manager
    check
    if [[ -d "$HOME/.zsh/znap" ]]; then
        log_success "Plugin manager: znap is installed"
    else
        log_error "Plugin manager: znap not found"
    fi
    
    # Check essential aliases
    check
    if zsh -c 'source ~/.zshrc && type l' &>/dev/null; then
        log_success "Aliases: Basic aliases are loaded"
    else
        log_warning "Aliases: May not be loading properly"
    fi
}

# Run all checks
run_all_checks() {
    log_info "Starting dotfiles validation..."
    echo

    check_command "zsh" "Zsh shell"
    check_command "git" "Git"
    echo

    check_zsh_config
    echo

    check_modular_config
    echo

    check_git_config
    echo

    check_vim_config
    echo

    check_homebrew
    echo

    check_bin_directory
    echo

    check_shell_functionality
    echo

    check_shell_performance
    echo
}

# Show summary
show_summary() {
    echo "==================== VALIDATION SUMMARY ===================="
    echo -e "Total checks: $TOTAL_CHECKS"
    echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
    echo -e "${YELLOW}Warnings: $WARNING_CHECKS${NC}"
    echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
    echo "=============================================================="

    if [[ $FAILED_CHECKS -gt 0 ]]; then
        echo
        log_error "Some critical checks failed. Please review the output above."
        echo "You may need to run './setup.sh' or './symlink.sh' to fix issues."
        return 1
    elif [[ $WARNING_CHECKS -gt 0 ]]; then
        echo
        log_warning "Some checks returned warnings. Your setup should work but may not be optimal."
        return 0
    else
        echo
        log_success "All checks passed! Your dotfiles are properly configured."
        return 0
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --zsh          Only check Zsh configuration"
    echo "  --modular      Only check modular configuration"
    echo "  --git          Only check Git configuration"
    echo "  --brew         Only check Homebrew"
    echo "  --bin          Only check bin directory"
    echo "  --shell        Only check shell functionality"
    echo "  --perf         Only check shell performance"
    echo ""
}

# Parse command line arguments
CHECK_ALL=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        --zsh|--modular|--git|--brew|--bin|--shell|--perf)
            CHECK_ALL=false
            break
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Run specific checks if requested
if [[ "$CHECK_ALL" == false ]]; then
    while [[ $# -gt 0 ]]; do
        case $1 in
            --zsh)
                check_zsh_config
                ;;
            --modular)
                check_modular_config
                ;;
            --git)
                check_git_config
                ;;
            --brew)
                check_homebrew
                ;;
            --bin)
                check_bin_directory
                ;;
            --shell)
                check_shell_functionality
                ;;
            --perf)
                check_shell_performance
                ;;
        esac
        shift
    done
else
    run_all_checks
fi

# Show summary and exit with appropriate code
show_summary

