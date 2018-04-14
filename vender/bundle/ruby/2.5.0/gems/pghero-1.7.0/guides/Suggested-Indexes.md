# How PgHero Suggests Indexes

1. Get the most time-consuming queries from [pg_stat_statements](http://www.postgresql.org/docs/9.3/static/pgstatstatements.html).

2. Parse queries with [pg_query](https://github.com/lfittl/pg_query).  Look for a single table with a `WHERE` clause that consists of only `=`, `IN`, `IS NULL` or `IS NOT NULL` and/or an `ORDER BY` clause.

3. Use the [pg_stats](http://www.postgresql.org/docs/current/static/view-pg-stats.html) view to get estimates about distinct rows and percent of `NULL` values for each column.

4. For each column in the `WHERE` clause, sort by the highest [cardinality](https://en.wikipedia.org/wiki/Cardinality_(SQL_statements)) (most unique values). This allows the database to narrow its search the fastest. Perform [row estimation](http://www.postgresql.org/docs/current/static/row-estimation-examples.html) to get the expected number of rows as we add columns to the index.

5. Continue this process with columns in the `ORDER BY` clause.

6. To make sure we don’t add useless columns, stop once we narrow it down to 50 rows in steps 5 or 6. Also, recheck the last columns to make sure they add value.

7. Profit :moneybag:

## TODO

- examples
