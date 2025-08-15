# Analytics & Performance Monitoring

This dotfiles repository includes comprehensive analytics and performance monitoring to help you optimize your development environment.

## 📊 Package Usage Analytics

Track which installed packages you actually use to identify bloat and optimize your setup.

### Features

- **Command Usage Tracking**: Automatically tracks which commands you run
- **Package Mapping**: Correlates commands to their source packages
- **Usage Analysis**: Identifies unused packages and usage patterns
- **Size Analysis**: Estimates space savings from removing unused packages
- **Historical Trends**: Tracks usage patterns over time

### Commands

```bash
# Analyze package usage (last 30 days)
make health-analytics
./scripts/analyze-package-usage.sh analyze

# Analyze specific time period
./scripts/analyze-package-usage.sh analyze 7    # Last 7 days
./scripts/analyze-package-usage.sh analyze 90   # Last 90 days

# Generate comprehensive usage report
./scripts/analyze-package-usage.sh report

# Clean old usage data
./scripts/analyze-package-usage.sh clean 60     # Keep last 60 days

# Set up usage tracking (first time)
./scripts/analyze-package-usage.sh setup
```

### Sample Output

```
🏆 Most Frequently Used Packages:
  127 uses: git
  89 uses: nvim
  76 uses: kubectl
  45 uses: docker
  32 uses: node

✅ Recently Used Packages (24 total):
  - git
  - nvim
  - kubectl
  - docker
  - node

🗑️  Unused Packages (8 total - consider removing):
  - scala
  - perl
  - graphviz
  - avro-tools

💡 To remove unused packages:
  brew uninstall scala perl graphviz avro-tools
```

## ⚡ Performance Monitoring

Monitor shell performance, startup times, and identify optimization opportunities.

### Features

- **Startup Time Tracking**: Monitors shell initialization performance
- **Plugin Performance**: Tracks individual plugin load times
- **Command Execution**: Monitors slow command executions
- **Memory Usage**: Tracks memory consumption patterns
- **Trend Analysis**: Detects performance regressions over time
- **Optimization Suggestions**: Provides actionable improvement recommendations

### Commands

```bash
# Run comprehensive performance analysis (includes dashboard)
make health-analytics

# Individual components:
./bin/perf-dashboard                         # Interactive dashboard
./scripts/performance-report.sh comprehensive   # Detailed analysis

# Specific analyses
./scripts/performance-report.sh startup      # Startup time analysis
./scripts/performance-report.sh plugins     # Plugin performance
./scripts/performance-report.sh commands    # Command execution times
./scripts/performance-report.sh trends      # Performance trends

# Export performance report
./bin/perf-dashboard --export ~/performance-report.txt
./scripts/performance-report.sh export ~/detailed-report.txt

# Auto-optimize detected issues
./bin/perf-dashboard --auto-optimize
```

### Performance Dashboard

```
🚀 Dotfiles Performance Dashboard
=================================

📊 Current Metrics:
  Shell Startup: 342ms  ✅
  Plugin Load: 156ms    ✅
  Memory Usage: 45MB    ✅

📈 Performance Trend:
  Last 7 startups (ms):
    289ms ▂▂
    334ms ▃▃
    298ms ▂▂
    342ms ▃▃
    356ms ▃▃
    321ms ▃▃
    308ms ▂▂

⚠️  Performance Analysis:
  🟡 Plugin 'kubectl' loading slowly (89ms)

💡 Optimization Suggestions:
  💡 Lazy-load kubectl completion
  💡 Consider replacing 'ls' alias with eza
  💡 Move heavy git config to lazy function
```

## 🔍 Comprehensive Analytics

Run all analytics together for a complete overview.

```bash
# Run comprehensive analytics (packages + performance + dashboard)
make health-analytics
```

## 📈 Data Collection

### Automatic Setup

The analytics system automatically sets up data collection when you source your `.zshrc`:

- **Usage tracking**: Records every command execution
- **Performance monitoring**: Tracks startup times, plugin loads, and command execution
- **Data rotation**: Automatically manages data file sizes
- **Privacy**: All data stays local on your machine

### Manual Setup

If analytics aren't working, set them up manually:

```bash
# Set up usage tracking
./scripts/analyze-package-usage.sh setup

# Verify analytics files are loaded
grep -q "usage-analytics.sh" ~/.zshrc && echo "Usage tracking: ✅"
grep -q "perf-monitor.sh" ~/.zshrc && echo "Performance monitoring: ✅"
```

## 📁 Data Storage

Analytics data is stored in `~/.config/dotfiles/`:

- `command-usage.log` - Command execution history
- `perf-data.csv` - Performance metrics (startup, plugins, commands)
- `package-mapping.cache` - Command to package mappings

### Data Privacy

- All analytics data stays on your local machine
- No data is transmitted anywhere
- Data files are automatically rotated to prevent excessive disk usage
- You can clear all data anytime: `rm -rf ~/.config/dotfiles/`

## 🛠️ Integration with Existing Tools

### Health Check Integration

The health check system now includes analytics status:

```bash
make health      # Includes analytics data collection status
```

### Profile Integration

Performance monitoring complements the existing profiling tools:

```bash
make health-profile     # Detailed startup profiling
make health-analytics   # Comprehensive performance monitoring including dashboard
```

## 🎯 Optimization Workflow

1. **Monitor**: Let the system collect data for a few days
2. **Analyze**: Run `make health-analytics` weekly
3. **Optimize**: Follow the suggestions provided
4. **Verify**: Check that optimizations improved performance
5. **Repeat**: Continuously monitor for regressions

### Example Optimization Cycle

```bash
# Week 1: Baseline
make health-analytics                    # Identify issues

# Week 2: Optimize
# - Lazy load slow plugins
# - Remove unused packages
# - Update tool configurations

# Week 3: Verify
make health-analytics                    # Confirm improvements
./scripts/performance-report.sh trends  # Check trend analysis
```

## 🔧 Troubleshooting

### No Usage Data

```bash
# Check if tracking is enabled
grep "usage-analytics" ~/.zshrc

# Set up tracking if missing
./scripts/analyze-package-usage.sh setup
source ~/.zshrc
```

### No Performance Data

```bash
# Check if performance monitoring is enabled
grep "perf-monitor" ~/.zshrc

# Verify data collection
ls -la ~/.config/dotfiles/perf-data.csv
```

### Slow Analytics

```bash
# Clean old data
./scripts/analyze-package-usage.sh clean 30
./scripts/performance-report.sh clean-old-data
```

## 📊 Understanding the Data

### Performance Thresholds

- **Startup Time**:
  - ✅ Good: < 500ms
  - ⚠️ Warning: 500-1000ms
  - 🔴 Critical: > 1000ms

- **Plugin Load**:
  - ✅ Good: < 50ms per plugin
  - ⚠️ Warning: 50-100ms per plugin
  - 🔴 Critical: > 100ms per plugin

- **Command Execution**:
  - ✅ Good: < 500ms
  - ⚠️ Warning: 500-2000ms
  - 🔴 Critical: > 2000ms

### Package Usage Patterns

- **High usage**: > 10 uses per week
- **Moderate usage**: 1-10 uses per week
- **Low usage**: < 1 use per week
- **Unused**: No usage in analysis period

Use this data to make informed decisions about which packages to keep, remove, or optimize.