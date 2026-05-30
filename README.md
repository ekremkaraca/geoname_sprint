# GeoName Sprint

A small Rails geography quiz game where players guess cities from a region and reveal them on a map.

## Stack

- Ruby 4.0.5
- Rails 8.1
- PostgreSQL
- Hotwire / Stimulus
- Leaflet
- OpenStreetMap tiles

## Setup

```bash
bin/setup
bin/rails db:setup
bin/rails server
````

## Tests

```bash
bin/rails test
bin/rails test:system
bin/rubocop
bundle exec brakeman --no-pager
bin/bundler-audit check --update
```

## Current Features

* Slug-based quiz pages
* City guessing
* Alias support
* Leaflet map markers
* Countdown timer
* Completion state

## Known Limitations

* Game state is browser-only
* No leaderboard yet
* Map center is currently region-specific
* External OSM tiles are used
