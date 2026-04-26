# No Ads Radio

Flutter client for the Radio Browser network.

## What It Does

- Discovers stations from Radio Browser mirror servers
- Shows most-clicked, top-voted, and recently clicked station lists
- Searches by name, country code, language, and tag
- Saves favorites locally
- Resolves stream URLs through `/json/url/{stationuuid}` before playback

## Notes

- The app sends a descriptive `User-Agent` to Radio Browser as requested by the API docs.
- Favorites are stored locally with `shared_preferences`.
- Cleartext network access is enabled for native targets because many radio streams still use plain `http`.
