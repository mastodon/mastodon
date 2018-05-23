# PgHero for Heroku

One click deployment

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/pghero/pghero)

## Authentication

Set the following variables in your environment.

```sh
heroku config:set PGHERO_USERNAME=link
heroku config:set PGHERO_PASSWORD=hyrule
```

## Query Stats

Query stats are enabled by default for Heroku databases - there’s nothing to do :tada:

For databases outside of Heroku, query stats can be enabled from the dashboard.

If you run into issues, [view the guide](Query-Stats.md).

## Historical Query Stats

To track query stats over time, create a table to store them.

```sql
CREATE TABLE "pghero_query_stats" (
  "id" serial primary key,
  "database" text,
  "user" text,
  "query" text,
  "query_hash" bigint,
  "total_time" float,
  "calls" bigint,
  "captured_at" timestamp
)
CREATE INDEX ON "pghero_query_stats" ("database", "captured_at")
```

This table can be in the current database or another database. If another database, run:

```sh
heroku config:set PGHERO_STATS_DATABASE_URL=...
```

Schedule the task below to run every 5 minutes.

```sh
rake pghero:capture_query_stats
```

Or with a scheduler like Clockwork, use:

```ruby
PgHero.capture_query_stats
```

After this, a time range slider will appear on the Queries tab.

## System Stats

CPU usage is available for Amazon RDS.  Add these variables to your environment:

```sh
heroku config:set PGHERO_ACCESS_KEY_ID=accesskey123
heroku config:set PGHERO_SECRET_ACCESS_KEY=secret123
heroku config:set PGHERO_DB_INSTANCE_IDENTIFIER=epona
```

## Customize

Minimum time for long running queries

```sh
heroku config:set PGHERO_LONG_RUNNING_QUERY_SEC=60 # default
```

Minimum average time for slow queries

```sh
heroku config:set PGHERO_SLOW_QUERY_MS=20 # default
```

Minimum calls for slow queries

```sh
heroku config:set PGHERO_SLOW_QUERY_CALLS=100 # default
```

Minimum connections for high connections warning

```sh
heroku config:set PGHERO_TOTAL_CONNECTIONS_THRESHOLD=100 # default
```
