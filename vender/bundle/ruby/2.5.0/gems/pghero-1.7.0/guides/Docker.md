# PgHero for Docker

PgHero is available as a [Docker image](https://hub.docker.com/r/ankane/pghero/).

```sh
docker run -ti -e DATABASE_URL=postgres://user:password@hostname:5432/dbname -p 8080:8080 ankane/pghero
```

And visit [http://localhost:8080](http://localhost:8080).

## Query Stats

Query stats can be enabled from the dashboard. If you run into issues, [view the guide](Query-Stats.md).

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

Schedule the task below to run every 5 minutes.

```sh
docker run -ti -e DATABASE_URL=... ankane/pghero bin/rake pghero:capture_query_stats
```

After this, a time range slider will appear on the Queries tab.

## Credits

Thanks to [Brian Morton](https://github.com/bmorton) for the [original Docker image](https://github.com/bmorton/pghero_solo).
