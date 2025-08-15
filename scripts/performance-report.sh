#!/usr/bin/env bash

# Performance Analysis & Reporting Script
# Comprehensive analysis of dotfiles performance patterns

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ANALYTICS_DIR="$HOME/.config/dotfiles"
PERF_DATA="$ANALYTICS_DIR/perf-data.csv"

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

# Generate comprehensive performance analysis
analyze_startup_performance() {
    log_info "Analyzing shell startup performance..."

    if [[ ! -f "$PERF_DATA" ]]; then
        log_warning "No performance data found"
        return 1
    fi

    echo
    echo "=== SHELL STARTUP ANALYSIS ==="
    echo

    # Startup time statistics
    local startup_data
    startup_data=$(grep "shell_startup_complete" "$PERF_DATA" | tail -50)

    if [[ -z "$startup_data" ]]; then
        echo "No startup data available"
        return 1
    fi

    echo "📈 Startup Time Statistics (last 50 shells):"
    echo "$startup_data" | gawk -F',' '{
        times[NR] = $3/1000000
        sum += $3/1000000
        if (NR == 1 || $3/1000000 < min) min = $3/1000000
        if (NR == 1 || $3/1000000 > max) max = $3/1000000
    } END {
        avg = sum/NR
        printf "  Average: %.0fms\n", avg
        printf "  Minimum: %.0fms\n", min
        printf "  Maximum: %.0fms\n", max
        printf "  Samples: %d\n", NR

        # Calculate percentiles
        asort(times)
        p50 = times[int(NR*0.5)]
        p90 = times[int(NR*0.9)]
        p95 = times[int(NR*0.95)]
        printf "  50th percentile: %.0fms\n", p50
        printf "  90th percentile: %.0fms\n", p90
        printf "  95th percentile: %.0fms\n", p95
    }'

    echo
    echo "📊 Startup Time Trend (last 20 shells):"
    echo "$startup_data" | tail -20 | awk -F',' '{
        time_ms = $3/1000000
        if (time_ms < 300) bar = "▁▁"
        else if (time_ms < 500) bar = "▂▂"
        else if (time_ms < 700) bar = "▃▃"
        else if (time_ms < 1000) bar = "▅▅"
        else if (time_ms < 1500) bar = "▆▆"
        else bar = "▇▇"

        date_time = $1
        gsub(/-/, "/", date_time)
        gsub(/ /, " ", date_time)
        printf "  %s: %.0fms %s\n", substr(date_time, 6, 11), time_ms, bar
    }'
}

# Analyze plugin performance
analyze_plugin_performance() {
    log_info "Analyzing plugin load performance..."

    if [[ ! -f "$PERF_DATA" ]]; then
        log_warning "No performance data found"
        return 1
    fi

    echo
    echo "=== PLUGIN PERFORMANCE ANALYSIS ==="
    echo

    local plugin_data
    plugin_data=$(grep "plugin_load" "$PERF_DATA" | tail -100)

    if [[ -z "$plugin_data" ]]; then
        echo "No plugin load data available"
        return 1
    fi

    echo "🔌 Plugin Load Times (average from last 100 loads):"
    echo "$plugin_data" | awk -F',' '{
        plugin = $5
        time_ms = $3/1000000
        total[plugin] += time_ms
        count[plugin]++
    } END {
        for (plugin in total) {
            avg = total[plugin]/count[plugin]
            printf "  %-20s: %.0fms (loaded %d times)\n", plugin, avg, count[plugin]
        }
    }' | sort -nr -k2

    echo
    echo "🐌 Slowest Plugin Loads (individual instances):"
    echo "$plugin_data" | awk -F',' '{print $5, $3/1000000}' | sort -nr -k2 | head -10 | while read -r plugin time; do
        printf "  %-20s: %.0fms\n" "$plugin" "$time"
    done
}

# Analyze command execution performance
analyze_command_performance() {
    log_info "Analyzing command execution performance..."

    if [[ ! -f "$PERF_DATA" ]]; then
        log_warning "No performance data found"
        return 1
    fi

    echo
    echo "=== COMMAND EXECUTION ANALYSIS ==="
    echo

    local command_data
    command_data=$(grep "command_exec" "$PERF_DATA" | tail -200)

    if [[ -z "$command_data" ]]; then
        echo "No command execution data available"
        return 1
    fi

    echo "⚡ Command Performance (last 200 executions):"
    echo "$command_data" | awk -F',' '{
        cmd = $5
        time_ms = $3/1000000
        total[cmd] += time_ms
        count[cmd]++
        if (time_ms > max[cmd]) max[cmd] = time_ms
    } END {
        for (cmd in total) {
            avg = total[cmd]/count[cmd]
            printf "  %-15s: avg %.0fms, max %.0fms (%d runs)\n", cmd, avg, max[cmd], count[cmd]
        }
    }' | sort -nr -k3

    echo
    echo "🐌 Slowest Command Executions:"
    echo "$command_data" | awk -F',' '{print $5, $3/1000000}' | sort -nr -k2 | head -10 | while read -r cmd time; do
        printf "  %-15s: %.0fms\n" "$cmd" "$time"
    done
}

# Analyze memory usage patterns
analyze_memory_usage() {
    log_info "Analyzing memory usage patterns..."

    if [[ ! -f "$PERF_DATA" ]]; then
        log_warning "No performance data found"
        return 1
    fi

    echo
    echo "=== MEMORY USAGE ANALYSIS ==="
    echo

    local memory_data
    memory_data=$(awk -F',' 'NF>=4 && $4>0 {print $4}' "$PERF_DATA" | tail -100)

    if [[ -z "$memory_data" ]]; then
        echo "No memory usage data available"
        return 1
    fi

    echo "💾 Memory Usage Statistics (last 100 measurements):"
    echo "$memory_data" | awk '{
        sum += $1
        if (NR == 1 || $1 < min) min = $1
        if (NR == 1 || $1 > max) max = $1
        mem[NR] = $1
    } END {
        avg = sum/NR
        printf "  Average: %.1fMB\n", avg
        printf "  Minimum: %.1fMB\n", min
        printf "  Maximum: %.1fMB\n", max
        printf "  Samples: %d\n", NR
    }'
}

# Generate optimization recommendations
generate_recommendations() {
    log_info "Generating optimization recommendations..."

    echo
    echo "=== OPTIMIZATION RECOMMENDATIONS ==="
    echo

    local recommendations_made=0

    # Check startup time
    if [[ -f "$PERF_DATA" ]]; then
        local avg_startup
        avg_startup=$(grep "shell_startup_complete" "$PERF_DATA" | tail -10 | awk -F',' '{sum+=$3} END {print sum/NR/1000000}')

        if [[ -n "$avg_startup" ]] && (( $(echo "$avg_startup > 1000" | bc -l 2>/dev/null || echo "0") )); then
            echo "🔴 CRITICAL: Slow shell startup (${avg_startup}ms)"
            echo "   Recommendations:"
            echo "   - Enable lazy loading for heavy plugins"
            echo "   - Review plugin necessity"
            echo "   - Use 'znap compile' for frequently sourced files"
            echo
            recommendations_made=1
        elif [[ -n "$avg_startup" ]] && (( $(echo "$avg_startup > 500" | bc -l 2>/dev/null || echo "0") )); then
            echo "🟡 WARNING: Moderate shell startup time (${avg_startup}ms)"
            echo "   Recommendations:"
            echo "   - Consider lazy loading some plugins"
            echo "   - Profile individual plugin load times"
            echo
            recommendations_made=1
        fi
    fi

    # Check for slow plugins
    if [[ -f "$PERF_DATA" ]]; then
        local slow_plugins
        slow_plugins=$(grep "plugin_load" "$PERF_DATA" | tail -50 | awk -F',' '$3/1000000 > 100 {print $5, $3/1000000}' | sort -nr -k2 | head -5)

        if [[ -n "$slow_plugins" ]]; then
            echo "🔌 PLUGIN OPTIMIZATION:"
            echo "$slow_plugins" | while read -r plugin time; do
                printf "   %s (%.0fms) - " "$plugin" "$time"
                case "$plugin" in
                    *git*) echo "Consider lazy loading git completions" ;;
                    *kubectl*) echo "Lazy load kubectl completion" ;;
                    *docker*) echo "Defer docker initialization" ;;
                    *) echo "Review if this plugin is necessary" ;;
                esac
            done
            echo
            recommendations_made=1
        fi
    fi

    # Check command performance
    if [[ -f "$PERF_DATA" ]]; then
        local slow_commands
        slow_commands=$(grep "command_exec" "$PERF_DATA" | tail -100 | awk -F',' '$3/1000000 > 1000 {print $5, $3/1000000}' | sort -nr -k2 | head -5)

        if [[ -n "$slow_commands" ]]; then
            echo "⚡ COMMAND OPTIMIZATION:"
            echo "$slow_commands" | while read -r cmd time; do
                printf "   %s (%.0fms) - " "$cmd" "$time"
                case "$cmd" in
                    git) echo "Large repo? Consider git aliases or faster git config" ;;
                    docker) echo "Consider docker context optimization" ;;
                    kubectl) echo "Large cluster? Use kubectl aliases" ;;
                    npm|yarn) echo "Consider using faster package managers" ;;
                    *) echo "Profile this command for optimization opportunities" ;;
                esac
            done
            echo
            recommendations_made=1
        fi
    fi

    # General recommendations
    echo "💡 GENERAL RECOMMENDATIONS:"
    echo "   - Regular cleanup: Run 'make clean' to remove unused symlinks"
    echo "   - Update tools: Keep brew packages updated for performance improvements"
    echo "   - Monitor trends: Run this analysis weekly to catch regressions"
    echo "   - Profile startup: Use 'make profile' for detailed startup analysis"
    echo

    if [[ $recommendations_made -eq 0 ]]; then
        echo "✅ EXCELLENT: No major performance issues detected!"
        echo "   Your dotfiles configuration is well optimized."
        echo
    fi
}

# Generate trend analysis
analyze_performance_trends() {
    log_info "Analyzing performance trends..."

    if [[ ! -f "$PERF_DATA" ]]; then
        log_warning "No performance data found"
        return 1
    fi

    echo
    echo "=== PERFORMANCE TRENDS ==="
    echo

    # Startup time trend over last 30 days
    local trend_data
    trend_data=$(grep "shell_startup_complete" "$PERF_DATA" | tail -100)

    if [[ -z "$trend_data" ]]; then
        echo "Insufficient data for trend analysis"
        return 1
    fi

    echo "📈 Startup Time Trend Analysis:"

    # Split data into old vs recent
    local old_avg recent_avg
    old_avg=$(echo "$trend_data" | head -50 | awk -F',' '{sum+=$3} END {if(NR>0) print sum/NR/1000000; else print 0}')
    recent_avg=$(echo "$trend_data" | tail -50 | awk -F',' '{sum+=$3} END {if(NR>0) print sum/NR/1000000; else print 0}')

    if [[ -n "$old_avg" && -n "$recent_avg" ]]; then
        local change
        change=$(echo "scale=1; $recent_avg - $old_avg" | bc -l 2>/dev/null || echo "0")
        local change_pct
        change_pct=$(echo "scale=1; ($recent_avg - $old_avg) / $old_avg * 100" | bc -l 2>/dev/null || echo "0")

        printf "  Older average: %.0fms\n" "$old_avg"
        printf "  Recent average: %.0fms\n" "$recent_avg"
        printf "  Change: %+.0fms (%+.1f%%)\n" "$change" "$change_pct"

        if (( $(echo "$change > 50" | bc -l 2>/dev/null || echo "0") )); then
            echo "  ⚠️  Performance has degraded - investigate recent changes"
        elif (( $(echo "$change < -50" | bc -l 2>/dev/null || echo "0") )); then
            echo "  ✅ Performance has improved!"
        else
            echo "  ➡️  Performance is stable"
        fi
    fi
}

# Export comprehensive report
export_comprehensive_report() {
    local output_file="${1:-$HOME/dotfiles-comprehensive-performance-report.txt}"
    log_info "Generating comprehensive performance report..."

    {
        echo "Comprehensive Dotfiles Performance Report"
        echo "Generated: $(date)"
        echo "=========================================="
        echo

        echo "SYSTEM INFORMATION:"
        echo "- OS: $(uname -s) $(uname -r)"
        echo "- Shell: $SHELL"
        echo "- Terminal: $TERM"
        echo "- Data points: $(wc -l < "$PERF_DATA" 2>/dev/null || echo "0")"
        echo "- Analysis period: $(get_analysis_period)"
        echo

        # Run all analyses
        analyze_startup_performance 2>/dev/null || echo "Startup analysis failed"
        analyze_plugin_performance 2>/dev/null || echo "Plugin analysis failed"
        analyze_command_performance 2>/dev/null || echo "Command analysis failed"
        analyze_memory_usage 2>/dev/null || echo "Memory analysis failed"
        analyze_performance_trends 2>/dev/null || echo "Trend analysis failed"
        generate_recommendations 2>/dev/null || echo "Recommendations failed"

    } > "$output_file"

    log_success "Comprehensive report saved to: $output_file"
}

# Get analysis period
get_analysis_period() {
    if [[ -f "$PERF_DATA" ]]; then
        local first_entry last_entry
        first_entry=$(tail -n +2 "$PERF_DATA" | head -1 | cut -d',' -f1)
        last_entry=$(tail -1 "$PERF_DATA" | cut -d',' -f1)

        if [[ -n "$first_entry" && -n "$last_entry" ]]; then
            echo "From $first_entry to $last_entry"
        else
            echo "No data"
        fi
    else
        echo "No data collected"
    fi
}

# Show help
show_help() {
    echo "Performance Analysis & Reporting"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  startup              Analyze shell startup performance"
    echo "  plugins              Analyze plugin load performance"
    echo "  commands             Analyze command execution performance"
    echo "  memory               Analyze memory usage patterns"
    echo "  trends               Analyze performance trends"
    echo "  recommendations      Generate optimization recommendations"
    echo "  comprehensive        Run all analyses"
    echo "  export [file]        Export comprehensive report to file"
    echo ""
    echo "Examples:"
    echo "  $0 startup           # Analyze startup times"
    echo "  $0 comprehensive     # Run full analysis"
    echo "  $0 export report.txt # Save full report to file"
}

# Main function
main() {
    case "${1:-comprehensive}" in
        startup)
            analyze_startup_performance
            ;;
        plugins)
            analyze_plugin_performance
            ;;
        commands)
            analyze_command_performance
            ;;
        memory)
            analyze_memory_usage
            ;;
        trends)
            analyze_performance_trends
            ;;
        recommendations)
            generate_recommendations
            ;;
        comprehensive)
            analyze_startup_performance
            analyze_plugin_performance
            analyze_command_performance
            analyze_memory_usage
            analyze_performance_trends
            generate_recommendations
            ;;
        export)
            export_comprehensive_report "$2"
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