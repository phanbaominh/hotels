# README

## Introduction

- Access deployed version using this link: https://hotels-0j6j.onrender.com/hotels. It is on free tier so take a while for the app to spin up
- Example usage with parameters:
  - Filter by destination: `https://hotels-0j6j.onrender.com/hotels?destination=1122`
  - Filter by hotels: `https://hotels-0j6j.onrender.com/hotels?hotels%5B%5D=SjyX&hotels%5B%5D=f8c9`

## Dependencies

- Ruby 3.1.3
- Bundler 2.4.20

## Setup

- Install ruby using [rbenv](https://github.com/rbenv/rbenv)
- Install bundle `gem install bundle`
- Go to projects folder
- Run `bundle`
- Run `bin/rails db:setup`

## Development

- Start up rails service `bin/rails s`
- Api endpoint is available at `localhost:3000/hotels`

## Testing

- Run `bin/rspec path/to/test/files/or/folder` or `bin/rspec` to test all
