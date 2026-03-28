# TMDB Netflix Demo

A native iOS movie browsing app inspired by Netflix, built with SwiftUI, Swift Concurrency, TMDB API, and a workspace + Swift Package structure.

![Demo](./demo.gif)

## What Was Prompted

This project was created from a prompt with these main requirements:

- create an iOS movie app like Netflix
- no movie playback feature
- use The Movie Database API
- home screen must have carousels such as trending, popular, top rated, upcoming
- pick one movie from `popular` and use it as the Netflix-style hero
- add a movie details screen
- add a search bar and search results screen
- use TMDB official docs as guidance

The project was then refined with follow-up prompts to:

- use Swift Concurrency more explicitly
- change the minimum supported iOS version to `26.0`
- switch image loading to `Nuke`
- fix hero image layout, gradient behavior, top-edge fill, and stretchy pull-down behavior

## What Was Built

- full-screen Home tab with:
  - hero banner sourced from TMDB `popular`
  - horizontal carousels for `Trending`, `Popular`, `Top Rated`, and `Upcoming`
- movie details screen with:
  - large backdrop header
  - metadata, overview, cast, and recommendations
- search flow with:
  - search entry screen
  - search results list
  - navigation into movie details
- TMDB API client using Swift Concurrency
- image loading via `NukeUI/LazyImage`

## Project Structure

```text
TMDBNetflix.xcworkspace
TMDBNetflix.xcodeproj
TMDBNetflix/
TMDBNetflixPackage/
TMDBNetflixUITests/
Config/
demo.gif
```

Most app logic lives in:

- `TMDBNetflixPackage/Sources/TMDBNetflixFeature/`

Key files:

- `TMDBNetflixPackage/Sources/TMDBNetflixFeature/TMDBNetflixRootView.swift`
- `TMDBNetflixPackage/Sources/TMDBNetflixFeature/HomeScreen.swift`
- `TMDBNetflixPackage/Sources/TMDBNetflixFeature/MovieDetailScreen.swift`
- `TMDBNetflixPackage/Sources/TMDBNetflixFeature/SearchScreen.swift`
- `TMDBNetflixPackage/Sources/TMDBNetflixFeature/TMDBClient.swift`
- `TMDBNetflixPackage/Sources/TMDBNetflixFeature/TMDBImageView.swift`

## How MCP Was Used

This project was created and verified with MCP tools instead of manual Xcode shell workflows.

### `XcodeBuildMCP`

Used to:

- scaffold the initial iOS workspace and SwiftUI app shell
- inspect active Xcode session defaults
- set workspace, scheme, simulator, and platform defaults
- build for iOS Simulator
- run unit tests on iOS Simulator
- launch the app in Simulator
- capture screenshots for visual QA

Typical MCP operations used during development:

- `session_show_defaults`
- `session_set_defaults`
- `scaffold_ios_project`
- `build_sim`
- `test_sim`
- `build_run_sim`
- `screenshot`

### Why MCP mattered here

It made the workflow deterministic:

- project scaffold was generated consistently
- builds and tests ran against a known simulator target
- UI issues on the hero banner were debugged from actual Simulator screenshots instead of guessing

## What Skills Were Used

### `xcodebuildmcp`

Used because this was an iOS app task that required:

- project scaffolding
- building
- simulator execution
- screenshot-based verification

### `swiftui-expert-skill`

Used to guide:

- modern SwiftUI navigation and state flow
- decomposition into reusable views
- correct use of SwiftUI APIs for current platform targets

### `swift-concurrency`

Used in a later pass when explicitly requested to harden concurrency.

That pass was used to:

- move the project to Swift 6 language mode
- set stricter concurrency behavior
- mark actor-crossing value types as `Sendable`
- keep UI-bound views on `@MainActor`
- handle async cancellation safely in screen loaders

## Implementation Notes

### TMDB

The app uses TMDB endpoints for:

- `/trending/movie/week`
- `/movie/popular`
- `/movie/top_rated`
- `/movie/upcoming`
- `/movie/{id}`
- `/search/movie`

TMDB docs referenced during implementation:

- https://developer.themoviedb.org/docs/getting-started
- https://developer.themoviedb.org/reference/getting-started

### Image Loading

The app uses `Nuke`:

- package: `https://github.com/kean/Nuke.git`
- UI layer: `NukeUI`
- image view abstraction: `LazyImage`

### Hero Banner Behavior

The home hero was refined through screenshot-driven iteration to:

- use a movie from the `Popular` feed
- render edge-to-edge at the top
- apply a full-width dark gradient overlay
- support stretchy pull-down behavior when overscrolling

## How To Run

1. Open `TMDBNetflix.xcworkspace` in Xcode.
2. Run the `TMDBNetflix` scheme.
3. Use a recent iOS Simulator.

The current minimum supported version is:

- `iOS 26.0`

## API Key

TMDB credentials are loaded from either:

- the `TMDB_API_KEY` environment variable
- `Config/Secrets.xcconfig` via `TMDB_API_KEY = your_key_here`

Setup:

1. Copy `Config/Secrets.example.xcconfig` to `Config/Secrets.xcconfig`.
2. Set `TMDB_API_KEY = your_key_here`.
3. Open `TMDBNetflix.xcworkspace` and run the app.

`Config/Secrets.xcconfig` is gitignored, so secrets stay out of the repository.

## Verification Performed

During development, the app was verified by:

- simulator builds
- simulator test runs
- repeated app launches in Simulator
- screenshot checks for hero image layout and image loading behavior

## Summary

This repository is not only the app itself, but also a record of an MCP-driven build workflow:

- prompt -> scaffold
- scaffold -> implement
- implement -> build/test
- build/test -> screenshot review
- screenshot review -> targeted UI fixes

That loop was used repeatedly until the current result was stable.
