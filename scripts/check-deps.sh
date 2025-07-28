#!/usr/bin/env bash

# Dependency checker and installer for dotfiles
# Verifies required tools are installed and optionally installs them

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
DEPS_CHECKED=0
DEPS_FOUND=0
DEPS_MISSING=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    DEPS_FOUND=$((DEPS_FOUND + 1))
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    DEPS_MISSING=$((DEPS_MISSING + 1))
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if a command exists
check_command() {
    local cmd="$1"
    local description="$2"
    local install_cmd="$3"

    DEPS_CHECKED=$((DEPS_CHECKED + 1))

    if command -v "$cmd" &> /dev/null; then
        local version=""
        case "$cmd" in
            git) version=$(git --version 2>/dev/null | head -1) ;;
            vim) version=$(vim --version 2>/dev/null | head -1) ;;
            zsh) version=$(zsh --version 2>/dev/null) ;;
            brew) version=$(brew --version 2>/dev/null | head -1) ;;
            starship) version=$(starship --version 2>/dev/null) ;;
            *) version="Available" ;;
        esac
        log_success "$description ($version)"
        return 0
    else
        log_error "$description (Missing)"
        if [[ -n "$install_cmd" ]]; then
            echo "    Install with: $install_cmd"
        fi
        return 1
    fi
}

# Check essential dependencies
check_essential_deps() {
    log_info "Checking essential dependencies..."

    check_command "git" "Git version control" "brew install git"
    check_command "zsh" "Zsh shell" "brew install zsh"
    check_command "vim" "Vim editor" "brew install vim"

    echo
}

# Check core dependencies (CI-friendly, no znap)
check_core_deps() {
    log_info "Checking core dependencies..."

    check_command "git" "Git version control" "brew install git"
    check_command "zsh" "Zsh shell" "brew install zsh"
    check_command "vim" "Vim editor" "brew install vim"
    check_command "bash" "Bash shell" "Should be available by default"

    echo
}

# Check shell enhancements
check_shell_deps() {
    log_info "Checking shell enhancement dependencies..."

    check_command "starship" "Starship prompt" "brew install starship"
    check_command "eza" "Modern ls replacement" "brew install eza"
    check_command "bat" "Modern cat replacement" "brew install bat"
    check_command "fzf" "Fuzzy finder" "brew install fzf"
    check_command "tree" "Directory tree viewer" "brew install tree"
    check_command "zoxide" "Smart cd command" "brew install zoxide"

    echo
}

# Check development tools
check_dev_deps() {
    log_info "Checking development tool dependencies..."

    check_command "brew" "Homebrew package manager" "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    check_command "curl" "HTTP client" "brew install curl"
    check_command "wget" "File downloader" "brew install wget"
    check_command "jq" "JSON processor" "brew install jq"
    check_command "rg" "Ripgrep search" "brew install ripgrep"

    echo
}

# Check language-specific tools
check_language_deps() {
    log_info "Checking language-specific dependencies..."

    # Python tools
    check_command "python3" "Python 3" "brew install python"
    check_command "pyenv" "Python version manager" "brew install pyenv"

    # Node.js tools
    check_command "node" "Node.js" "brew install node"
    check_command "npm" "Node package manager" "Comes with Node.js"

    # Java tools
    check_command "java" "Java runtime" "brew install openjdk"
    check_command "mvn" "Maven build tool" "brew install maven"

    echo
}

# Check optional tools
check_optional_deps() {
    log_info "Checking optional dependencies..."

    check_command "kubectl" "Kubernetes CLI" "brew install kubectl"
    check_command "docker" "Docker container runtime" "brew install docker"
    check_command "gh" "GitHub CLI" "brew install gh"

    echo
}

# Check Homebrew packages from Brewfile
check_brewfile() {
    log_info "Checking Brewfile packages..."

    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local brewfile="$dotfiles_dir/install/Brewfile"

    if [[ ! -f "$brewfile" ]]; then
        log_warning "Brewfile not found at $brewfile"
        return
    fi

    if ! command -v brew &> /dev/null; then
        log_error "Homebrew not installed, cannot check Brewfile"
        return
    fi

    local missing_packages=()
    local total_packages=0
    local checked_packages=0

    # Count total packages first
    total_packages=$(grep -E '^(brew|cask)' "$brewfile" | wc -l)
    
    echo -n "  📦 Checking $total_packages packages"

    # Check each package in Brewfile
    while IFS= read -r line; do
        if [[ "$line" =~ ^brew[[:space:]]+\"([^\"]+)\" ]]; then
            local package="${BASH_REMATCH[1]}"
            ((checked_packages++))
            
            # Show progress indicator
            if (( checked_packages % 10 == 0 )); then
                echo -n "."
            fi
            
            if ! brew list "$package" &> /dev/null; then
                missing_packages+=("$package")
            fi
        elif [[ "$line" =~ ^cask[[:space:]]+\"([^\"]+)\" ]]; then
            local cask="${BASH_REMATCH[1]}"
            ((checked_packages++))
            
            # Show progress indicator
            if (( checked_packages % 10 == 0 )); then
                echo -n "."
            fi
            
            if ! brew list --cask "$cask" &> /dev/null; then
                missing_packages+=("$cask (cask)")
            fi
        fi
    done < "$brewfile"

    echo # New line after progress dots
    
    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        log_success "All Brewfile packages are installed"
    else
        log_warning "Missing Brewfile packages: ${missing_packages[*]}"
        echo "    Install with: brew bundle --file=$brewfile"
    fi

    echo
}

# Check for znap plugin manager
check_znap() {
    log_info "Checking znap plugin manager..."

    if [[ -d "$HOME/.zsh/znap" ]]; then
        log_success "znap plugin manager is installed"
    else
        log_error "znap plugin manager not found"
        echo "    Install with: git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/.zsh/znap"
    fi

    # Check znap plugins file
    if [[ -f "$HOME/.znap-plugins.zsh" ]]; then
        log_success "znap plugins configuration found"
    else
        log_error "znap plugins configuration missing"
        echo "    Should be symlinked from dotfiles/zsh/.znap-plugins.zsh"
    fi

    echo
}

# Install missing essential dependencies
install_essentials() {
    log_info "Installing essential missing dependencies..."

    # Install Homebrew first if missing
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for this session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    # Install essential tools
    local essentials=("git" "zsh" "vim" "starship")
    for tool in "${essentials[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_info "Installing $tool..."
            brew install "$tool" || log_error "Failed to install $tool"
        fi
    done

    # Install znap if missing
    if [[ ! -d "$HOME/.zsh/znap" ]]; then
        log_info "Installing znap plugin manager..."
        git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/.zsh/znap
    fi

    log_success "Essential dependencies installation complete!"
}

# Show installation suggestions
show_suggestions() {
    log_info "Installation suggestions:"

    echo "1. 🏠 Essential setup:"
    echo "   ./scripts/check-deps.sh --install-essentials"
    echo

    echo "2. 📦 Homebrew packages:"
    echo "   brew bundle --file=install/Brewfile"
    echo

    echo "3. 🔗 Symlink dotfiles:"
    echo "   ./symlink.sh"
    echo

    echo "4. ✅ Validate setup:"
    echo "   ./validate.sh"
    echo

    echo "5. 🚀 Performance check:"
    echo "   ./scripts/profile-shell.sh --startup"
    echo
}

# Show summary
show_summary() {
    echo "==================== DEPENDENCY SUMMARY ===================="
    echo -e "Total checked: $DEPS_CHECKED"
    echo -e "${GREEN}Found: $DEPS_FOUND${NC}"
    echo -e "${RED}Missing: $DEPS_MISSING${NC}"
    echo "=============================================================="

    if [[ $DEPS_MISSING -gt 0 ]]; then
        echo
        log_warning "Some dependencies are missing. Consider running:"
        echo "  ./scripts/check-deps.sh --install-essentials"
        echo "  brew bundle --file=install/Brewfile"
        return 1
    else
        echo
        log_success "All dependencies are satisfied! 🎉"
        return 0
    fi
}

# Show help
show_help() {
    echo "Dependency Checker for Dotfiles"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help                Show this help message"
    echo "  --essential           Check only essential dependencies"
    echo "  --core                Check core dependencies (CI-friendly)"
    echo "  --shell               Check shell enhancement tools"
    echo "  --dev                 Check development tools"
    echo "  --languages           Check language-specific tools"
    echo "  --optional            Check optional tools"
    echo "  --brewfile            Check Brewfile packages"
    echo "  --install-essentials  Install missing essential dependencies"
    echo "  --suggestions         Show installation suggestions"
    echo ""
    echo "Examples:"
    echo "  $0                           # Check all dependencies"
    echo "  $0 --essential               # Check only essential tools"
    echo "  $0 --core                    # Check core tools (CI-friendly)"
    echo "  $0 --install-essentials      # Install missing essentials"
    echo ""
}

# Main function
main() {
    case "${1:-}" in
        --help)
            show_help
            exit 0
            ;;
        --essential)
            check_essential_deps
            check_znap
            ;;
        --core)
            check_core_deps
            ;;
        --shell)
            check_shell_deps
            ;;
        --dev)
            check_dev_deps
            ;;
        --languages)
            check_language_deps
            ;;
        --optional)
            check_optional_deps
            ;;
        --brewfile)
            check_brewfile
            ;;
        --install-essentials)
            install_essentials
            exit 0
            ;;
        --suggestions)
            show_suggestions
            exit 0
            ;;
        "")
            # Run all checks
            check_essential_deps
            check_shell_deps
            check_dev_deps
            check_language_deps
            check_optional_deps
            check_brewfile
            check_znap
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac

    show_summary
}

# Run dependency checker
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
