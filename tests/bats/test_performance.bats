#!/usr/bin/env bats

# Performance tests
# Measures shell startup time with a real, portable timer (/usr/bin/time -p)

load setup_suite

# Measure one zsh startup, printing elapsed milliseconds.
# Uses /usr/bin/time -p which is POSIX and available on macOS and Linux.
measure_zsh_startup_ms() {
    local seconds
    seconds=$(/usr/bin/time -p zsh -i -c 'exit' 2>&1 >/dev/null | awk '/^real/{print $2}')
    [[ -n "$seconds" ]] || return 1
    awk -v s="$seconds" 'BEGIN { printf "%d", s * 1000 }'
}

@test "Shell startup performance" {
    if [[ ! -x /usr/bin/time ]]; then
        skip "/usr/bin/time not available for performance measurement"
    fi
    if ! command -v zsh >/dev/null 2>&1; then
        skip "zsh not available"
    fi

    # Average of 3 runs
    local total=0 count=0 ms
    for _ in 1 2 3; do
        if ms=$(measure_zsh_startup_ms); then
            total=$((total + ms))
            count=$((count + 1))
        fi
    done

    if [[ "$count" -eq 0 ]]; then
        skip "Could not obtain a valid startup time measurement"
    fi

    local average=$((total / count))
    echo "Average zsh startup time over $count runs: ${average}ms" >&3

    # Startup should be under 3 seconds for reasonable UX
    local threshold_ms=3000
    [ "$average" -le "$threshold_ms" ]
}

@test "Plugin performance check" {
    if [[ ! -f "$ANALYTICS_DIR/perf-data.csv" ]]; then
        skip "No performance data available for plugin regression testing"
    fi

    # Get recent plugin load times (ns -> ms)
    local recent_plugin_ms
    recent_plugin_ms=$(grep "plugin_load" "$ANALYTICS_DIR/perf-data.csv" | tail -5 \
        | awk -F',' '{sum+=$3; n+=1} END { if (n > 0) printf "%d", sum/n/1000000; else print 0 }')

    if [[ -z "$recent_plugin_ms" || "$recent_plugin_ms" -eq 0 ]]; then
        skip "No recent plugin performance data"
    fi

    echo "Recent plugin load time: ${recent_plugin_ms}ms" >&3

    # Plugins should load within 500ms
    [ "$recent_plugin_ms" -le 500 ]
}
