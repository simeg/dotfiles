#!/usr/bin/env bash

# Shell performance profiling and optimization script
# Helps identify slow parts of shell initialization

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Profile shell startup time
profile_startup_time() {
    log_info "Profiling shell startup time..."
    
    local runs=5
    local total_ms=0
    local times=()
    
    for i in $(seq 1 $runs); do
        local start_time
        start_time=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
        zsh -c 'exit' 2>/dev/null
        local end_time
        end_time=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
        local duration=$((end_time - start_time))
        
        times+=("${duration}ms")
        total_ms=$((total_ms + duration))
        
        echo "  Run $i: ${duration}ms"
    done
    
    local avg_ms=$((total_ms / runs))
    echo
    log_info "Average startup time: ${avg_ms}ms"
    
    if [[ $avg_ms -lt 500 ]]; then
        log_success "Shell startup is very fast"
    elif [[ $avg_ms -lt 1000 ]]; then
        log_success "Shell startup is fast"
    elif [[ $avg_ms -lt 2000 ]]; then
        log_warning "Shell startup is moderate"
    else
        log_error "Shell startup is slow (consider optimization)"
    fi
    
    echo
}

# Profile zsh with zprof
profile_with_zprof() {
    log_info "Running detailed zsh profiling..."
    
    local profile_script
    profile_script=$(mktemp)
    cat > "$profile_script" << 'EOF'
zmodload zsh/zprof
source ~/.zshrc
zprof
EOF
    
    echo "=== ZSH PROFILING OUTPUT ==="
    zsh "$profile_script"
    echo "=========================="
    
    rm -f "$profile_script"
    echo
}

# Test individual config loading times
profile_config_sections() {
    log_info "Testing individual configuration section load times..."
    
    local config_dir="$HOME/.config/zsh"
    local configs=("exports.zsh" "path.zsh" "aliases.zsh" "functions.zsh" "misc.zsh")
    
    if [[ -f "$HOME/.config/zsh/private.zsh" ]]; then
        configs+=("private.zsh")
    fi
    
    echo "| Config File | Load Time |"
    echo "|-------------|-----------|"
    
    for config in "${configs[@]}"; do
        local config_file="$config_dir/$config"
        if [[ -f "$config_file" ]]; then
            local start_time
        start_time=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
            zsh -c "source '$config_file'" 2>/dev/null || true
            local end_time
        end_time=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
            local duration=$((end_time - start_time))
            
            printf "| %-11s | %6dms |\n" "$config" "$duration"
        fi
    done
    
    echo
}

# Test plugin loading times
profile_plugins() {
    log_info "Testing plugin loading times..."
    
    if [[ ! -f "$HOME/.znap-plugins.zsh" ]]; then
        log_warning "No znap plugins file found"
        return
    fi
    
    local start_time
    start_time=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
    zsh -c "
        source ~/.zsh/znap/znap.zsh
        source ~/.znap-plugins.zsh
    " 2>/dev/null || true
    local end_time
    end_time=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
    local duration=$((end_time - start_time))
    
    echo "Plugin loading time: ${duration}ms"
    
    if [[ $duration -lt 200 ]]; then
        log_success "Plugin loading is fast"
    elif [[ $duration -lt 500 ]]; then
        log_warning "Plugin loading is moderate"
    else
        log_error "Plugin loading is slow"
    fi
    
    echo
}

# Test completion loading
profile_completions() {
    log_info "Testing completion loading time..."
    
    local start_time
    start_time=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
    zsh -c "
        autoload -U compinit
        compinit -C
    " 2>/dev/null || true
    local end_time
    end_time=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
    local duration=$((end_time - start_time))
    
    echo "Completion loading time: ${duration}ms"
    
    if [[ $duration -lt 100 ]]; then
        log_success "Completion loading is fast"
    elif [[ $duration -lt 300 ]]; then
        log_warning "Completion loading is moderate"
    else
        log_error "Completion loading is slow"
    fi
    
    echo
}

# Provide optimization suggestions
provide_suggestions() {
    log_info "Performance optimization suggestions:"
    
    echo "1. 🚀 Fast loading techniques:"
    echo "   - Use 'znap eval' for slow commands (pyenv, nvm, etc.)"
    echo "   - Load plugins asynchronously when possible"
    echo "   - Use 'compinit -C' to skip security checks"
    echo
    
    echo "2. 🧹 Configuration cleanup:"
    echo "   - Remove unused plugins and aliases"
    echo "   - Consolidate PATH modifications"
    echo "   - Use conditional loading for optional tools"
    echo
    
    echo "3. 📊 Monitoring:"
    echo "   - Run 'validate.sh --perf' regularly"
    echo "   - Use 'zprof' to identify bottlenecks"
    echo "   - Profile after adding new plugins"
    echo
    
    echo "4. 🔧 znap optimizations:"
    echo "   - Enable znap compile: znap compile ~/.zshrc"
    echo "   - Use znap eval for external command evaluation"
    echo "   - Prefer znap source over direct sourcing"
    echo
}

# Main performance analysis
run_full_analysis() {
    echo "========================================="
    echo "         Shell Performance Analysis"
    echo "========================================="
    echo
    
    profile_startup_time
    profile_config_sections
    profile_plugins
    profile_completions
    provide_suggestions
    
    log_success "Performance analysis complete!"
}

# Show help
show_help() {
    echo "Shell Performance Profiler"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help         Show this help message"
    echo "  --startup      Profile startup time only"
    echo "  --zprof        Run detailed zsh profiling"
    echo "  --configs      Test config file loading times"
    echo "  --plugins      Test plugin loading times"
    echo "  --suggestions  Show optimization suggestions"
    echo ""
    echo "Examples:"
    echo "  $0                  # Run full analysis"
    echo "  $0 --startup        # Quick startup time check"
    echo "  $0 --zprof          # Detailed profiling"
    echo ""
}

# Command line interface
main() {
    case "${1:-}" in
        --help)
            show_help
            exit 0
            ;;
        --startup)
            profile_startup_time
            ;;
        --zprof)
            profile_with_zprof
            ;;
        --configs)
            profile_config_sections
            ;;
        --plugins)
            profile_plugins
            ;;
        --suggestions)
            provide_suggestions
            ;;
        "")
            run_full_analysis
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Check dependencies
check_dependencies() {
    # Check if we have high-resolution time command
    if ! command -v gdate &> /dev/null && ! date +%s%3N &> /dev/null; then
        log_warning "High-resolution timing not available. Install 'coreutils' for better precision:"
        log_warning "  brew install coreutils"
        echo
    fi
}

# Run the profiler
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_dependencies
    main "$@"
fi