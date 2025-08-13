#!/usr/bin/env bash

# Enhanced Analytics System
# Extends existing analytics with productivity metrics, command frequency analysis, and predictive optimization

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
# CYAN='\033[0;36m'  # Unused - keeping for potential future use
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

# Configuration
ANALYTICS_DIR="$HOME/.config/dotfiles"
USAGE_LOG="$ANALYTICS_DIR/command-usage.log"
PERF_DATA="$ANALYTICS_DIR/perf-data.csv"
PRODUCTIVITY_LOG="$ANALYTICS_DIR/productivity-metrics.log"
COMMAND_FREQ_CACHE="$ANALYTICS_DIR/command-frequency.cache"
OPTIMIZATION_HISTORY="$ANALYTICS_DIR/optimization-history.log"

# Ensure analytics directory exists
mkdir -p "$ANALYTICS_DIR"

# =============================================================================
# PRODUCTIVITY METRICS
# =============================================================================

# Calculate development productivity metrics
analyze_productivity_metrics() {
    local days="${1:-7}"
    log_info "🚀 Analyzing productivity metrics for last $days days..."
    
    if [[ ! -f "$USAGE_LOG" ]]; then
        log_warning "No usage data found. Enable tracking first."
        return 1
    fi
    
    local cutoff_date
    cutoff_date=$(date -d "$days days ago" +%s 2>/dev/null || date -v-"$days"d +%s)
    
    # Development-related commands
    local dev_commands git_commands file_commands
    dev_commands=$(mktemp)
    git_commands=$(mktemp)
    file_commands=$(mktemp)
    
    # Filter and categorize commands
    awk -F',' -v cutoff="$cutoff_date" '$1 >= cutoff {print $2}' "$USAGE_LOG" > "$dev_commands"
    
    # Git productivity
    grep -E '^git|^gh|^hub' "$dev_commands" > "$git_commands" 2>/dev/null || touch "$git_commands"
    
    # File manipulation productivity
    grep -E '^(nvim|vim|code|nano|emacs|cat|less|more|grep|rg|find|fd|ls|eza|tree)' "$dev_commands" > "$file_commands" 2>/dev/null || touch "$file_commands"
    
    echo
    log_success "=== PRODUCTIVITY METRICS ($days days) ==="
    echo
    
    # Overall activity
    local total_commands unique_commands
    total_commands=$(wc -l < "$dev_commands")
    unique_commands=$(sort "$dev_commands" | uniq | wc -l)
    
    log_info "📈 Overall Activity:"
    echo "  Total commands executed: $total_commands"
    echo "  Unique commands used: $unique_commands"
    echo "  Command diversity: $(( (unique_commands * 100) / (total_commands + 1) ))%"
    echo
    
    # Git productivity
    local git_count git_commits
    git_count=$(wc -l < "$git_commands")
    git_commits=$(grep -c '^git commit\|^git add\|^git push' "$git_commands" 2>/dev/null || echo 0)
    
    log_info "🔧 Git Productivity:"
    echo "  Git commands: $git_count"
    echo "  Estimated commits/pushes: $git_commits"
    echo "  Git usage frequency: $(( git_count * 100 / (total_commands + 1) ))%"
    echo
    
    # File editing productivity
    local edit_count view_count
    edit_count=$(grep -cE '^(nvim|vim|code|nano|emacs)' "$file_commands" 2>/dev/null || echo 0)
    view_count=$(grep -cE '^(cat|less|more|bat)' "$file_commands" 2>/dev/null || echo 0)
    
    log_info "📝 File Management:"
    echo "  Editing sessions: $edit_count"
    echo "  File views: $view_count"
    echo "  Edit/view ratio: $(( (edit_count * 100) / (view_count + edit_count + 1) ))%"
    echo
    
    # Time-based patterns
    analyze_time_patterns "$dev_commands" "$days"
    
    # Efficiency metrics
    analyze_efficiency_metrics "$dev_commands"
    
    # Store productivity metrics
    local timestamp
    timestamp=$(date +%s)
    {
        echo "$timestamp,total_commands,$total_commands"
        echo "$timestamp,unique_commands,$unique_commands"
        echo "$timestamp,git_commands,$git_count"
        echo "$timestamp,edit_sessions,$edit_count"
    } >> "$PRODUCTIVITY_LOG"
    
    # Cleanup
    rm -f "$dev_commands" "$git_commands" "$file_commands"
}

# Analyze time-based usage patterns
analyze_time_patterns() {
    local commands_file="$1"
    local days="$2"
    
    log_info "⏰ Time Patterns Analysis:"
    
    if [[ ! -f "$USAGE_LOG" ]]; then
        echo "  No detailed timestamp data available"
        return
    fi
    
    # Analyze by hour of day (requires enhanced logging)
    local cutoff_date
    cutoff_date=$(date -d "$days days ago" +%s 2>/dev/null || date -v-"$days"d +%s)
    
    # Most active hours (simplified analysis - using date command instead of strftime)
    local activity_by_hour
    activity_by_hour=$(awk -F',' -v cutoff="$cutoff_date" '
        $1 >= cutoff {
            # Use system date command for macOS compatibility
            cmd = "date -r " $1 " +%H"
            cmd | getline hour
            close(cmd)
            count[hour]++
        }
        END {
            for (h in count) {
                printf "%02d:00 %d\n", h, count[h]
            }
        }' "$USAGE_LOG" | sort -n)
    
    if [[ -n "$activity_by_hour" ]]; then
        echo "  Most active hours:"
        echo "$activity_by_hour" | tail -3 | while read -r hour count; do
            echo "    $hour: $count commands"
        done
    else
        echo "  Activity pattern analysis requires enhanced logging"
    fi
    echo
}

# Analyze efficiency metrics
analyze_efficiency_metrics() {
    local commands_file="$1"
    
    log_info "⚡ Efficiency Metrics:"
    
    # Command repetition patterns (potential for aliasing)
    local repeated_commands
    repeated_commands=$(sort "$commands_file" | uniq -c | sort -nr | head -10)
    
    echo "  Most repeated commands (alias candidates):"
    echo "$repeated_commands" | head -5 | while read -r count cmd; do
        if [[ $count -gt 5 ]]; then
            echo "    $cmd: $count times (consider alias)"
        fi
    done
    echo
    
    # Long command analysis
    local long_commands
    long_commands=$(awk 'length($0) > 50' "$commands_file" | sort | uniq -c | sort -nr | head -5)
    
    if [[ -n "$long_commands" ]]; then
        echo "  Long commands (function candidates):"
        echo "$long_commands" | while read -r count cmd; do
            echo "    ${cmd:0:50}... ($count times)"
        done
        echo
    fi
}

# =============================================================================
# COMMAND FREQUENCY ANALYSIS
# =============================================================================

# Analyze command frequency patterns
analyze_command_frequency() {
    local days="${1:-30}"
    log_info "📊 Analyzing command frequency patterns for last $days days..."
    
    if [[ ! -f "$USAGE_LOG" ]]; then
        log_warning "No usage data found"
        return 1
    fi
    
    local cutoff_date temp_commands freq_analysis
    cutoff_date=$(date -d "$days days ago" +%s 2>/dev/null || date -v-"$days"d +%s)
    temp_commands=$(mktemp)
    freq_analysis=$(mktemp)
    
    # Extract recent commands
    awk -F',' -v cutoff="$cutoff_date" '$1 >= cutoff {print $2}' "$USAGE_LOG" > "$temp_commands"
    
    # Generate frequency analysis
    sort "$temp_commands" | uniq -c | sort -nr > "$freq_analysis"
    
    echo
    log_success "=== COMMAND FREQUENCY ANALYSIS ($days days) ==="
    echo
    
    # Top commands
    log_info "🏆 Most Frequently Used Commands:"
    head -15 "$freq_analysis" | while read -r count cmd; do
        local percentage
        local total_commands
        total_commands=$(wc -l < "$temp_commands")
        percentage=$(( (count * 100) / total_commands ))
        printf "  %3d%% (%3d uses): %s\n" "$percentage" "$count" "$cmd"
    done
    echo
    
    # Command categories
    analyze_command_categories "$freq_analysis"
    
    # Frequency trends
    analyze_frequency_trends "$temp_commands" "$days"
    
    # Command diversity metrics
    analyze_command_diversity "$freq_analysis" "$temp_commands"
    
    # Cache frequency data for later use
    cp "$freq_analysis" "$COMMAND_FREQ_CACHE"
    
    # Cleanup
    rm -f "$temp_commands" "$freq_analysis"
}

# Analyze commands by category
analyze_command_categories() {
    local freq_file="$1"
    
    log_info "📁 Command Categories:"
    
    # Define categories
    local git_cmds file_cmds system_cmds dev_cmds
    git_cmds=$(grep -E 'git|gh|hub' "$freq_file" | awk '{sum+=$1} END {print sum+0}')
    file_cmds=$(grep -E 'nvim|vim|cat|ls|eza|tree|find|fd|grep|rg|less|more' "$freq_file" | awk '{sum+=$1} END {print sum+0}')
    system_cmds=$(grep -E 'ps|top|htop|btop|kill|systemctl|brew|apt|yum' "$freq_file" | awk '{sum+=$1} END {print sum+0}')
    dev_cmds=$(grep -E 'npm|node|python|go|cargo|mvn|make|docker|kubectl' "$freq_file" | awk '{sum+=$1} END {print sum+0}')
    
    local total_categorized
    total_categorized=$((git_cmds + file_cmds + system_cmds + dev_cmds))
    
    if [[ $total_categorized -gt 0 ]]; then
        echo "  Git/VCS:           $git_cmds commands ($(( git_cmds * 100 / total_categorized ))%)"
        echo "  File Management:   $file_cmds commands ($(( file_cmds * 100 / total_categorized ))%)"
        echo "  System Admin:      $system_cmds commands ($(( system_cmds * 100 / total_categorized ))%)"
        echo "  Development:       $dev_cmds commands ($(( dev_cmds * 100 / total_categorized ))%)"
    fi
    echo
}

# Analyze frequency trends over time
analyze_frequency_trends() {
    local commands_file="$1"
    local days="$2"
    
    log_info "📈 Frequency Trends:"
    
    # Compare recent vs older usage patterns
    local recent_period
    recent_period=$(( days / 3 ))  # Last third of the period
    
    local recent_cutoff
    recent_cutoff=$(date -d "$recent_period days ago" +%s 2>/dev/null || date -v-"$recent_period"d +%s)
    
    # Get recent command frequency
    local recent_top older_top
    recent_top=$(awk -F',' -v cutoff="$recent_cutoff" '$1 >= cutoff {print $2}' "$USAGE_LOG" | sort | uniq -c | sort -nr | head -5)
    older_top=$(sort "$commands_file" | uniq -c | sort -nr | head -5)
    
    echo "  Recent trends (last $recent_period days):"
    echo "$recent_top" | while read -r count cmd; do
        echo "    $cmd: $count uses"
    done
    echo
    
    # Identify emerging commands
    local emerging_commands
    emerging_commands=$(comm -23 <(echo "$recent_top" | awk '{print $2}' | sort) <(echo "$older_top" | awk '{print $2}' | sort))
    
    if [[ -n "$emerging_commands" ]]; then
        echo "  🆕 Emerging commands (new in recent usage):"
        echo "$emerging_commands" | while read -r cmd; do echo "    $cmd"; done
        echo
    fi
}

# Analyze command diversity
analyze_command_diversity() {
    local freq_file="$1"
    local commands_file="$2"
    
    log_info "🎯 Command Diversity Metrics:"
    
    local total_commands unique_commands top_10_usage
    total_commands=$(wc -l < "$commands_file")
    unique_commands=$(wc -l < "$freq_file")
    top_10_usage=$(head -10 "$freq_file" | awk '{sum+=$1} END {print sum+0}')
    
    local diversity_score concentration_ratio
    diversity_score=$(( (unique_commands * 100) / (total_commands + 1) ))
    concentration_ratio=$(( (top_10_usage * 100) / (total_commands + 1) ))
    
    echo "  Diversity score: $diversity_score% ($unique_commands unique commands)"
    echo "  Top 10 concentration: $concentration_ratio% of all usage"
    echo "  Command variety: $(get_variety_assessment "$diversity_score" "$concentration_ratio")"
    echo
}

# Get variety assessment
get_variety_assessment() {
    local diversity="$1"
    local concentration="$2"
    
    if [[ $diversity -gt 15 && $concentration -lt 70 ]]; then
        echo "Excellent - diverse command usage"
    elif [[ $diversity -gt 10 && $concentration -lt 80 ]]; then
        echo "Good - balanced command usage"
    elif [[ $concentration -gt 90 ]]; then
        echo "Narrow - consider expanding toolset"
    else
        echo "Moderate - room for optimization"
    fi
}

# =============================================================================
# PREDICTIVE OPTIMIZATION
# =============================================================================

# Generate predictive optimization suggestions
generate_predictive_optimizations() {
    log_info "🔮 Generating predictive optimization suggestions..."
    
    local suggestions_file
    suggestions_file=$(mktemp)
    local suggestions_made=0
    
    echo
    log_success "=== PREDICTIVE OPTIMIZATION SUGGESTIONS ==="
    echo
    
    # Analyze command patterns for optimization opportunities
    if [[ -f "$COMMAND_FREQ_CACHE" ]]; then
        # Alias opportunities
        analyze_alias_opportunities "$suggestions_file"
        
        # Function opportunities
        analyze_function_opportunities "$suggestions_file"
        
        # Performance optimizations
        analyze_performance_optimizations "$suggestions_file"
        
        # Workflow optimizations
        analyze_workflow_optimizations "$suggestions_file"
        
        # Tool upgrade suggestions
        analyze_tool_upgrades "$suggestions_file"
    fi
    
    # Display suggestions
    if [[ -s "$suggestions_file" ]]; then
        cat "$suggestions_file"
        suggestions_made=$(wc -l < "$suggestions_file")
        
        # Log optimization suggestion
        echo "$(date +%s),suggestions_generated,$suggestions_made" >> "$OPTIMIZATION_HISTORY"
    else
        log_success "🎉 Your workflow is already well optimized!"
    fi
    
    rm -f "$suggestions_file"
}

# Analyze alias opportunities
analyze_alias_opportunities() {
    local suggestions_file="$1"
    
    # Find frequently used long commands
    local alias_candidates
    alias_candidates=$(awk '$1 > 10 && length($2) > 15 {print $1, $2}' "$COMMAND_FREQ_CACHE" | head -5)
    
    if [[ -n "$alias_candidates" ]]; then
        echo "🔗 Alias Opportunities:" >> "$suggestions_file"
        echo "$alias_candidates" | while read -r count cmd; do
            local suggested_alias
            suggested_alias=$(echo "$cmd" | awk '{print substr($1,1,3) substr($2,1,2)}' | tr -d '-')
            echo "  alias $suggested_alias='$cmd'  # Used $count times" >> "$suggestions_file"
        done
        echo >> "$suggestions_file"
    fi
}

# Analyze function opportunities
analyze_function_opportunities() {
    local suggestions_file="$1"
    
    # Find command patterns that could be functions
    local function_candidates
    function_candidates=$(awk '$1 > 5 && $2 ~ /&&|\|/ {print $1, $2}' "$COMMAND_FREQ_CACHE" | head -3)
    
    if [[ -n "$function_candidates" ]]; then
        echo "⚙️ Function Opportunities:" >> "$suggestions_file"
        echo "$function_candidates" | while read -r count cmd; do
            local func_name
            func_name=$(echo "$cmd" | awk '{print $1}' | sed 's/-/_/g')_combo
            echo "  Create function '$func_name' for: ${cmd:0:50}... (used $count times)" >> "$suggestions_file"
        done
        echo >> "$suggestions_file"
    fi
}

# Analyze performance optimization opportunities
analyze_performance_optimizations() {
    local suggestions_file="$1"
    
    # Check for slow commands that could be optimized
    if [[ -f "$PERF_DATA" ]]; then
        local slow_frequent_commands
        slow_frequent_commands=$(join -1 2 -2 5 <(sort -k2,2 "$COMMAND_FREQ_CACHE") <(grep "command_exec" "$PERF_DATA" | awk -F',' '$3/1000000 > 1000 {print $5}' | sort) | sort -nr | head -3)
        
        if [[ -n "$slow_frequent_commands" ]]; then
            echo "⚡ Performance Optimizations:" >> "$suggestions_file"
            echo "$slow_frequent_commands" | while read -r count cmd _; do
                case "$cmd" in
                    find*)
                        echo "  Replace 'find' with 'fd' for faster file searches (used $count times)" >> "$suggestions_file"
                        ;;
                    grep*)
                        echo "  Replace 'grep' with 'rg' (ripgrep) for faster searches (used $count times)" >> "$suggestions_file"
                        ;;
                    ls*)
                        echo "  You already use 'eza' - ensure it's properly aliased (used $count times)" >> "$suggestions_file"
                        ;;
                    *)
                        echo "  Consider optimizing '$cmd' command (slow + frequent: $count uses)" >> "$suggestions_file"
                        ;;
                esac
            done
            echo >> "$suggestions_file"
        fi
    fi
}

# Analyze workflow optimization opportunities
analyze_workflow_optimizations() {
    local suggestions_file="$1"
    
    # Find command sequences that could be optimized
    local git_workflow docker_workflow
    git_workflow=$(grep -c 'git add\|git commit\|git push' "$COMMAND_FREQ_CACHE" 2>/dev/null | head -1 || echo "0")
    docker_workflow=$(grep -c 'docker build\|docker run\|docker push' "$COMMAND_FREQ_CACHE" 2>/dev/null | head -1 || echo "0")
    
    if [[ $git_workflow -gt 10 ]]; then
        echo "🔄 Workflow Optimizations:" >> "$suggestions_file"
        echo "  Consider git aliases: 'gac' for 'git add . && git commit', 'gp' for 'git push'" >> "$suggestions_file"
    fi
    
    if [[ $docker_workflow -gt 5 ]]; then
        echo "  Consider docker-compose for repeated docker workflows" >> "$suggestions_file"
    fi
    
    if [[ $git_workflow -gt 10 || $docker_workflow -gt 5 ]]; then
        echo >> "$suggestions_file"
    fi
}

# Analyze tool upgrade opportunities
analyze_tool_upgrades() {
    local suggestions_file="$1"
    
    echo "🔧 Tool Upgrade Suggestions:" >> "$suggestions_file"
    
    # Check for outdated tool usage patterns
    if grep -q '^cat ' "$COMMAND_FREQ_CACHE" 2>/dev/null; then
        echo "  Consider using 'bat' instead of 'cat' for syntax highlighting" >> "$suggestions_file"
    fi
    
    if grep -q '^top ' "$COMMAND_FREQ_CACHE" 2>/dev/null; then
        echo "  Consider using 'htop' or 'btop' instead of 'top' for better interface" >> "$suggestions_file"
    fi
    
    if grep -q '^curl ' "$COMMAND_FREQ_CACHE" 2>/dev/null; then
        echo "  Consider 'httpie' (http) for more user-friendly HTTP requests" >> "$suggestions_file"
    fi
    
    echo >> "$suggestions_file"
}

# =============================================================================
# COMPREHENSIVE ANALYTICS
# =============================================================================

# Run comprehensive enhanced analytics
run_comprehensive_analytics() {
    local days="${1:-30}"
    
    clear
    echo -e "${PURPLE}🚀 Enhanced Dotfiles Analytics Dashboard${NC}"
    echo "========================================"
    echo
    
    # Run all analytics components
    analyze_productivity_metrics "$days"
    analyze_command_frequency "$days"
    generate_predictive_optimizations
    
    # Integration with existing analytics
    log_info "🔗 Integration with existing analytics..."
    if command -v ./scripts/analyze-package-usage.sh >/dev/null 2>&1; then
        echo
        ./scripts/analyze-package-usage.sh analyze "$days"
    fi
    
    if command -v ./bin/perf-dashboard >/dev/null 2>&1; then
        echo
        ./bin/perf-dashboard metrics
    fi
    
    echo
    log_success "✨ Enhanced analytics complete!"
    echo
    log_info "💾 Data stored in: $ANALYTICS_DIR"
    log_info "📊 Run 'make analytics-enhanced' to see this report again"
}

# Export comprehensive report
export_enhanced_report() {
    local output_file="${1:-$HOME/enhanced-analytics-report.txt}"
    log_info "📋 Generating comprehensive enhanced analytics report..."
    
    {
        echo "Enhanced Dotfiles Analytics Report"
        echo "Generated: $(date)"
        echo "=================================="
        echo
        
        # Run all analytics and capture output
        analyze_productivity_metrics 30 2>&1
        echo
        analyze_command_frequency 30 2>&1
        echo
        generate_predictive_optimizations 2>&1
        
    } > "$output_file"
    
    log_success "Enhanced analytics report saved to: $output_file"
}

# Show help
show_help() {
    echo "Enhanced Analytics System"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  comprehensive [days]    Run complete enhanced analytics (default: 30 days)"
    echo "  productivity [days]     Analyze productivity metrics only"
    echo "  frequency [days]        Analyze command frequency patterns only" 
    echo "  optimize                Generate predictive optimization suggestions"
    echo "  export [file]           Export comprehensive report"
    echo ""
    echo "Examples:"
    echo "  $0 comprehensive 7      # Last 7 days comprehensive analysis"
    echo "  $0 productivity 14      # 14-day productivity metrics"
    echo "  $0 frequency 30         # 30-day command frequency analysis"
    echo "  $0 optimize             # Get optimization suggestions"
    echo "  $0 export report.txt    # Export full report"
}

# Main function
main() {
    case "${1:-comprehensive}" in
        comprehensive)
            run_comprehensive_analytics "${2:-30}"
            ;;
        productivity)
            analyze_productivity_metrics "${2:-30}"
            ;;
        frequency)
            analyze_command_frequency "${2:-30}"
            ;;
        optimize)
            generate_predictive_optimizations
            ;;
        export)
            export_enhanced_report "$2"
            ;;
        --help|help)
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi