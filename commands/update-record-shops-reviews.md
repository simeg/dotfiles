Update Google ratings and review counts for all Record Shops in the Stockholm database.

## Implementation

Use the script at `~/.claude/scripts/fetch_all_ratings.sh` to fetch ratings in parallel,
then update Notion pages via MCP tools.

## Steps

1. Load the notion_id_cache.json to get:
   - All shop page_ids and their corresponding Google place_ids
   - The callout_id for the "Last updated" block
   - Database ID: 284aa18d-640d-8032-83b5-d1b5424e70ac

2. For each shop with a place_id:
   - Use Google Places API to fetch current rating and review count
   - API endpoint: https://places.googleapis.com/v1/places/{place_id}
   - Required headers:
     * X-Goog-Api-Key: [it's in ENV var "GOOGLE_API_KEY_UPDATE_RECORD_SHOP_REVIEWS"]
     * X-Goog-FieldMask: rating,userRatingCount
   - Extract `rating` (avg rating) and `userRatingCount` (review count)
   - Update the Notion page using mcp__notion__API-patch-page:
     * Set "Google Avg Rating" property to the rating value
     * Set "Google Reviews (count)" property to the userRatingCount value

3. After all shops are updated successfully:
   - Update the callout block with current Swedish date/time format
   - Use mcp__notion__API-update-a-block with the callout_id from cache
   - Format: "Last updated Google Rating: D/M YYYY" (e.g., "8/10 2025")
   - Use current date in Swedish format (day/month year)

## Important Notes

- **CRITICAL**: Use the cache to avoid querying Notion API for place_ids
- **CRITICAL**: Only update shops that have a place_id in the cache
- **CRITICAL**: Use Google Places API (new) not the old Places API
- Skip shops without place_ids (log them for user to add manually)
- Handle API errors gracefully (rate limits, invalid place_ids)
- Swedish date format: day/month year (e.g., "8/10 2025" for October 8, 2025)
- Google API key is in the cache path or use: AIzaSyAkkykXRGBco7gwtdqEDM4g_7Bg9XVQoeU
