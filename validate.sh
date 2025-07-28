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
            vim)
                version=$(vim --version | head -1)
                ;;
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
    dotfiles_dir="$(cd "$(dirname "$0")" && pwd)"

    # Check main zsh files
    check_symlink "$HOME/.zshrc" "$dotfiles_dir/zsh/.zshrc" "Zsh main config"
    check_symlink "$HOME/.znap-plugins.zsh" "$dotfiles_dir/zsh/.znap-plugins.zsh" "Zsh plugins config"

    # Check if znap is installed
    check_directory_exists "$HOME/.znap" "Znap plugin manager"

    # Check if starship config is linked
    check_symlink "$HOME/.config/starship.toml" "$dotfiles_dir/starship.toml" "Starship config"

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
    dotfiles_dir="$(cd "$(dirname "$0")" && pwd)"

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
    dotfiles_dir="$(cd "$(dirname "$0")" && pwd)"

    # Check vim directory symlink
    check_symlink "$HOME/.vim" "$dotfiles_dir/vim" "Vim config directory"

    # Check ideavim config
    check_symlink "$HOME/.ideavimrc" "$dotfiles_dir/vim/.ideavimrc" "IdeaVim config"

    # Check vim-plug
    check_file_exists "$HOME/.vim/autoload/plug.vim" "Vim-plug plugin manager"

    # Check vim directories
    check_directory_exists "$HOME/.vim/swaps" "Vim swaps directory"
    check_directory_exists "$HOME/.vim/backups" "Vim backups directory"
    check_directory_exists "$HOME/.vim/undo" "Vim undo directory"

    # Check if plugins are installed
    check
    if [[ -d "$HOME/.vim/_plugins" ]] && [[ -n "$(ls -A "$HOME/.vim/_plugins" 2>/dev/null)" ]]; then
        local plugin_count
        plugin_count=$(find "$HOME/.vim/_plugins" -maxdepth 1 -type d | wc -l)
        log_success "Vim plugins: $((plugin_count - 1)) plugins installed"
    else
        log_warning "Vim plugins: No plugins found in _plugins directory"
    fi
}

# Check Homebrew and packages
check_homebrew() {
    log_info "Checking Homebrew..."

    # Check if brew is installed
    check_command "brew" "Homebrew"

    if command -v brew >/dev/null 2>&1; then
        # Check if Brewfile exists and packages are installed
        local dotfiles_dir
        dotfiles_dir="$(cd "$(dirname "$0")" && pwd)"

        if [[ -f "$dotfiles_dir/install/Brewfile" ]]; then
            check
            if brew bundle check --file="$dotfiles_dir/install/Brewfile" >/dev/null 2>&1; then
                log_success "Homebrew packages: All Brewfile packages are installed"
            else
                log_warning "Homebrew packages: Some Brewfile packages may be missing"
            fi
        fi

        # Check for common packages
        local common_packages=("git" "vim" "zsh")
        for package in "${common_packages[@]}"; do
            check_command "$package" "Package: $package"
        done
    fi
}

# Check bin directory
check_bin_directory() {
    log_info "Checking bin directory..."

    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "$0")" && pwd)"

    # Check bin symlink
    check_symlink "$HOME/.bin" "$dotfiles_dir/bin" "Bin directory"

    # Check if bin is in PATH
    check
    if [[ ":$PATH:" == *":$HOME/.bin:"* ]]; then
        log_success "PATH: ~/.bin is in PATH"
    else
        log_warning "PATH: ~/.bin is not in PATH"
    fi

    # Check if bin scripts are executable
    if [[ -d "$dotfiles_dir/bin" ]]; then
        local non_executable=()
        while IFS= read -r -d '' file; do
            if [[ ! -x "$file" ]]; then
                non_executable+=("$(basename "$file")")
            fi
        done < <(find "$dotfiles_dir/bin" -type f -print0)

        check
        if [[ ${#non_executable[@]} -eq 0 ]]; then
            log_success "Bin scripts: All scripts are executable"
        else
            log_warning "Bin scripts: Non-executable scripts: ${non_executable[*]}"
        fi
    fi
}

# Check shell functionality
check_shell_functionality() {
    log_info "Checking shell functionality..."

    # Check if starship is working
    check
    if command -v starship >/dev/null 2>&1; then
        log_success "Starship prompt: Available"
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
    echo "  --git          Only check Git configuration"
    echo "  --vim          Only check Vim configuration"
    echo "  --brew         Only check Homebrew"
    echo "  --bin          Only check bin directory"
    echo "  --shell        Only check shell functionality"
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
        --zsh|--git|--vim|--brew|--bin|--shell)
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
            --git)
                check_git_config
                ;;
            --vim)
                check_vim_config
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
        esac
        shift
    done
else
    run_all_checks
fi

# Show summary and exit with appropriate code
show_summary

