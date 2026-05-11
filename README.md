# No Ads Radio

A lightweight internet radio application built with Flutter for Android and iOS.

The project started from a simple frustration: many free radio apps are overloaded with ads, tracking, unnecessary complexity, and poor user experience. No Ads Radio aims to provide a cleaner and simpler alternative focused primarily on listening.

The app uses the Radio Browser network for station discovery and streaming.

## Features

* Discover stations from Radio Browser mirror servers
* Browse most-clicked, top-voted, and recently played stations
* Search by station name, country, language, and tags
* Save favorite stations locally
* Resolve stream URLs dynamically before playback
* Cross-platform support for Android and iOS

## Technical Notes

* Built with Flutter
* Uses the Radio Browser API
* Favorites are stored locally using shared_preferences
* Sends a descriptive User-Agent as requested by the Radio Browser API documentation
* Cleartext network access is enabled for native targets because many radio streams still use plain http

## Goals

* Keep the application lightweight and easy to use
* Avoid intrusive advertising and unnecessary tracking
* Maintain a clean and reliable listening experience
* Keep the architecture simple and maintainable

## Status

Active development.