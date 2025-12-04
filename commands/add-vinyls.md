Add multiple albums to my Vinylsamling page in Notion at once.

## Input Format

Provide albums as a list, one per line or separated by semicolons. Each album should
include:
- Artist/band name
- Album title
- Year
- Optional: purchase price, purchased from, acquisition date

Examples:
```
Eric Clapton, E.C. Was Here, 1975, 70 SEK, Stockholm - Mickes Skivor, today
The Beatles, Abbey Road, 1969
Pink Floyd - Dark Side of the Moon - 1973 - 100 SEK - Discogs
```

## Steps

1. Parse the user's input to extract individual albums from the list
2. Launch multiple general-purpose agents in parallel (one per album) using the
Task tool
3. Each agent should execute the `/add-vinyl` command with that album's information
4. Wait for all agents to complete using AgentOutputTool if needed
5. After all albums are processed, provide a summary showing:
   - Number of albums successfully added
   - List of albums added with their corrected spelling (from Discogs)
   - Any albums that failed (with reason)
6. Update the notion_id_cache.json:
   - Query the database to get all newly created page IDs
   - Add them to ~/.claude/notion_id_cache.json with proper structure
   - Update the metadata section with today's date and increment total_pages count

## Important Notes

- **CRITICAL**: DO NOT add any emojis to the Notion pages
- **CRITICAL**: Launch all agents in parallel using a SINGLE message with multiple
Task tool calls
- **CRITICAL**: Each agent must use the `/add-vinyl` command - do NOT duplicate
the logic
- **CRITICAL**: In your prompt to each agent, instruct them to execute the
`/add-vinyl` command with the specific album information
- Each album inherits all the behavior from `/add-vinyl` including:
  * Fuzzy search with typo handling
  * Discogs as source of truth for spelling
  * Using master release URLs instead of specific release URLs
  * Inverted name order for new artists
  * Checking existing artists for naming consistency
- If an album fails, the others should still complete successfully
