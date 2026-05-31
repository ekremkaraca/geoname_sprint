# GeoName Sprint

A timed geography quiz built with Rails, Stimulus, Leaflet, and OpenStreetMap.

## Features

- City guessing gameplay
- Alias support
- Leaflet map markers
- Countdown timer
- Dark/light UI
- System tests for gameplay

## Stack

- Ruby 4.0.5
- Rails 8.1
- PostgreSQL
- Hotwire / Stimulus
- Importmap
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

## Notes

This app currently stores gameplay state in the browser. No leaderboard or user accounts yet.
