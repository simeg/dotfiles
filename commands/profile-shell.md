---
allowed-tools: Bash, Read
description: Profile zsh startup and summarize what's slow
---

# Profile zsh startup

Run the existing performance profiler and summarize the results in plain English.

1. Run `make health-profile` from the repo root. It uses zprof to capture per-plugin/per-source load times.

2. Capture the slowest 10 entries. For each, explain in one sentence what the entry is (znap plugin name, sourced file, eval'd init, etc.) and whether it's avoidable.

3. Compare total startup time to the documented baseline in `.config/zsh/.znap-plugins.zsh` (which mentions "428ms → Optimized: 282ms"). If startup is now significantly above that baseline, flag it — something has regressed.

4. Recommend the top 1–3 actions if any (lazy-load X, drop Y, replace Z). If everything is within budget, just say so — don't invent work.

Be concise. Tables over prose.
