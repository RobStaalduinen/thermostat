# README

Thermostat API with asynchronous writing and consistent retrieval.

Uses a Redis caching layer to hold on to posted data until persistence, so that readings
can be retrieved and included in stats prior to persistence completing.

Built with:
* Ruby 2.6.5
* Rails 5.1.7
* Redis 5.0.8
* PostgreSQL
* Sidekiq
* RSpec
