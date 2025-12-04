Add a new album to my Vinylsamling page in Notion.

## Steps

1. Find the Discogs master release using the Discogs MCP server:
   - Use `mcp__discogs__search` to search for the album (include artist and title from user input)
   - **CRITICAL**: Set format="Vinyl" to exclude CDs and other formats
   - The search is fuzzy and will handle typos in artist/album names
   - Filter results for type="release" to get actual releases
   - Find the best matching release (verify it's reasonably close to user's input)
   - Use `mcp__discogs__get_release` with the release_id to get full details
   - **CRITICAL**: Extract the master_id from the release details (if available)
   - **CRITICAL**: Use `mcp__discogs__get_master_release` with the master_id to get the master release
   - **CRITICAL**: Use the MASTER RELEASE URL (format: https://www.discogs.com/master/{master_id}) NOT the specific release URL
   - If no master_id exists, fall back to the regular release URL
   - **Use the CORRECT spelling from Discogs** for artist and title (Discogs is the source of truth)
2. Check existing artists in Notion database:
   - Query the Vinylsamling database to get existing entries
   - Check if the artist (from Discogs) already exists in the database
   - If the artist exists, use the EXACT same naming format as existing entries
   - If the artist doesn't exist, convert to inverted name order:
     * "Eric Clapton" → "Clapton, Eric"
     * "The Beatles" → "Beatles, The"
     * "Pink Floyd" → "Pink Floyd" (single names stay as-is)
3. Use the Notion MCP server to add a new page to the "Vinylsamling" database
   - **CRITICAL**: DO NOT add any emojis to the Notion page
   - **CRITICAL**: ALWAYS set "Ny" = True (checkbox must be checked)
4. Fill in these required fields (using corrected spelling from Discogs):
   - Artist/band name (in inverted order, or matching existing format)
   - Album title (correct spelling from Discogs)
   - Year (from Discogs)
   - Discogs URL
   - **CRITICAL**: "Ny" checkbox MUST be set to True
5. Fill in these optional fields (if provided by user):
   - Inköpspris (purchase price)
   - Köpt från (purchased from)
   - Införskaffningsdatum (acquisition date, default to today if user says "bought today")
6. **CRITICAL**: Find and add a cover image (this step is MANDATORY):
   - First: Extract the cover image from the Discogs release details (images array)
   - If Discogs has no image: Try the English Wikipedia page for the **album** (not the artist) and extract cover image
   - If Wikipedia has no page or no image: Search Amazon.com for the album and extract cover image
7. **CRITICAL**: Use that image as the cover for the new Notion page (using mcp__notion__API-patch-page)
   - You MUST add a cover image - never skip this step
   - Also add the vinyl record icon: {"type": "external", "external": {"url": "https://www.notion.so/icons/vinyl-record_lightgray.svg"}}
8. Confirm when done, showing the correct spelling used
9. Update the notion_id_cache.json:
   - Query the database to get the newly created page's ID
   - Add it to ~/.claude/notion_id_cache.json with proper structure:
     * title: The artist name (as stored)
     * parent_database: "1f3aa18d-640d-8180-8395-d7e6ea5e45e1"
     * url: The page URL from Notion
   - Update the metadata section with today's date and increment total_pages count

## Important Notes

- **CRITICAL**: DO NOT add any emojis to the Notion page
- **CRITICAL**: ALWAYS set "Ny" = True (checkbox must be checked) - this is MANDATORY
- **CRITICAL**: ALWAYS add a cover image to the Notion page - this is MANDATORY (never skip this step)
- **CRITICAL**: ALWAYS add the vinyl record icon to the page
- **CRITICAL**: Always use the Discogs MCP server (`mcp__discogs__search`, `mcp__discogs__get_release`, and `mcp__discogs__get_master_release`) instead of web scraping
- **CRITICAL**: Always filter Discogs searches with format="Vinyl" to exclude CDs and other formats
- **CRITICAL**: Always use the MASTER RELEASE URL (https://www.discogs.com/master/{master_id}) instead of specific release URLs - master releases group all variants together
- **CRITICAL**: Discogs is the source of truth for spelling - always use the correct artist/title from Discogs, not the user's input
- **CRITICAL**: Check existing artists in Notion first and match their naming format exactly
- **CRITICAL**: For new artists, use inverted name order (e.g., "Clapton, Eric" not "Eric Clapton")
- Discogs search is fuzzy and will handle typos in the user's input
- Discogs MCP server is the primary source for both URLs and cover images
- Wikipedia is the fallback if Discogs has no image (must be the album's page, not the artist's)
- Amazon.com is the final fallback if neither Discogs nor Wikipedia have images
- Optional fields (price, source, date) are only filled if user provides them
- When user says "bought today", use today's date for Införskaffningsdatum
