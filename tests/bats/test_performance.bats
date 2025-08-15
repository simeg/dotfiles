#!/usr/bin/env bats

# Performance regression tests migrated from test_advanced.sh
# Tests shell startup performance, memory usage, and plugin performance

load setup_suite

# Helper function to check if bc is available
check_bc() {
    command -v bc >/dev/null 2>&1
}

@test "Shell startup performance" {
    if ! check_bc; then
        skip "bc (calculator) not available for performance tests"
    fi
    
    # Measure current startup time (average of 3 runs for speed)
    local total_time=0
    for i in {1..3}; do
        local single_time
        single_time=$(time (zsh -c 'exit') 2>&1 | grep real | sed 's/real[[:space:]]*//' | sed 's/s//')
        # Convert to milliseconds
        local ms_time
        ms_time=$(echo "$single_time * 1000" | bc -l 2>/dev/null || echo "1000")
        total_time=$(echo "$total_time + $ms_time" | bc -l 2>/dev/null || echo "3000")
    done
    local current_time
    current_time=$(echo "$total_time / 3" | bc -l 2>/dev/null || echo "1000")
    
    echo "Current startup time: $(printf "%.0f" "$current_time")ms" >&3
    
    # Startup should be under 3 seconds for reasonable UX
    local threshold=3000
    local is_fast
    is_fast=$(echo "$current_time <= $threshold" | bc -l 2>/dev/null || echo "1")
    [ "$is_fast" -eq 1 ]
}

@test "Shell startup performance regression check" {
    if ! check_bc; then
        skip "bc (calculator) not available for performance tests"
    fi
    
    # Measure current startup time (average of 3 runs)
    local total_time=0
    for i in {1..3}; do
        local single_time
        single_time=$(time (zsh -c 'exit') 2>&1 | grep real | sed 's/real[[:space:]]*//' | sed 's/s//')
        # Convert to milliseconds
        local ms_time
        ms_time=$(echo "$single_time * 1000" | bc -l 2>/dev/null || echo "1000")
        total_time=$(echo "$total_time + $ms_time" | bc -l 2>/dev/null || echo "3000")
    done
    local current_time
    current_time=$(echo "$total_time / 3" | bc -l 2>/dev/null || echo "1000")
    
    echo "Current startup time: $(printf "%.0f" "$current_time")ms" >&3
    
    # Load baseline if it exists
    if [[ -f "$PERF_BASELINE" ]] && command -v jq >/dev/null 2>&1; then
        local baseline_time threshold
        baseline_time=$(jq -r '.shell_startup_ms // 1000' "$PERF_BASELINE" 2>/dev/null || echo "1000")
        threshold=$(echo "$baseline_time * 1.5" | bc -l 2>/dev/null || echo "1500")  # 50% regression threshold for tests
        
        echo "Baseline startup time: $(printf "%.0f" "$baseline_time")ms" >&3
        echo "Regression threshold: $(printf "%.0f" "$threshold")ms" >&3
        
        local has_regression
        has_regression=$(echo "$current_time > $threshold" | bc -l 2>/dev/null || echo "0")
        if [[ "$has_regression" -eq 1 ]]; then
            echo "Performance regression detected: $(printf "%.0f" "$current_time")ms > $(printf "%.0f" "$threshold")ms" >&3
            return 1
        fi
    else
        echo "No performance baseline found or jq not available, creating new baseline" >&3
        mkdir -p "$ANALYTICS_DIR"
        echo "{\"shell_startup_ms\": $current_time, \"created\": \"$(date -Iseconds)\"}" > "$PERF_BASELINE"
    fi
}

@test "Memory usage check" {
    # Measure current memory usage (in KB)
    local current_memory
    current_memory=$(ps -o rss= -p $$ | awk '{print $1}')
    
    echo "Current memory usage: ${current_memory}KB" >&3
    
    # Memory usage should be reasonable (under 100MB for shell)
    [ "$current_memory" -lt 100000 ]
}

@test "Memory usage regression check" {
    if ! check_bc; then
        skip "bc (calculator) not available for performance tests"
    fi
    
    # Measure current memory usage (in KB)
    local current_memory
    current_memory=$(ps -o rss= -p $$ | awk '{print $1}')
    
    echo "Current memory usage: ${current_memory}KB" >&3
    
    # Load baseline if it exists
    if [[ -f "$PERF_BASELINE" ]] && command -v jq >/dev/null 2>&1; then
        local baseline_memory threshold
        baseline_memory=$(jq -r '.memory_usage_kb // 50000' "$PERF_BASELINE" 2>/dev/null || echo "50000")
        threshold=$(echo "$baseline_memory * 2.0" | bc -l 2>/dev/null || echo "100000")  # 100% regression threshold for tests
        
        echo "Baseline memory usage: ${baseline_memory}KB" >&3
        
        if [[ $current_memory -gt $(printf "%.0f" "$threshold") ]]; then
            echo "Memory regression detected: ${current_memory}KB > $(printf "%.0f" "$threshold")KB" >&3
            return 1
        fi
    else
        # Update baseline with memory info
        if [[ -f "$PERF_BASELINE" ]] && command -v jq >/dev/null 2>&1; then
            jq ". + {\"memory_usage_kb\": $current_memory}" "$PERF_BASELINE" > "$PERF_BASELINE.tmp" && mv "$PERF_BASELINE.tmp" "$PERF_BASELINE"
        fi
    fi
}

@test "Plugin performance check" {
    if [[ ! -f "$ANALYTICS_DIR/perf-data.csv" ]]; then
        skip "No performance data available for plugin regression testing"
    fi
    
    if ! check_bc; then
        skip "bc (calculator) not available for performance tests"
    fi
    
    # Get recent plugin load times
    local recent_plugin_time
    recent_plugin_time=$(grep "plugin_load" "$ANALYTICS_DIR/perf-data.csv" | tail -5 | awk -F',' '{sum+=$3} END {print sum/NR/1000000}' 2>/dev/null || echo "0")
    
    if [[ "$recent_plugin_time" == "0" ]]; then
        skip "No recent plugin performance data"
    fi
    
    echo "Recent plugin load time: $(printf "%.0f" "$recent_plugin_time")ms" >&3
    
    # Check if plugins are loading too slowly (500ms threshold for tests)
    local is_fast
    is_fast=$(echo "$recent_plugin_time <= 500" | bc -l 2>/dev/null || echo "1")
    [ "$is_fast" -eq 1 ]
}