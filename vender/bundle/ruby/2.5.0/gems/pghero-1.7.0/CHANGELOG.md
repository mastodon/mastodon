## 1.7.0

- Fixed migrations for Rails 5.1+
- Added `analyze`, `analyze_tables`, and `analyze_all` methods
- Added `pghero:analyze` rake task
- Fixed system stats display issue

## 1.6.5

- Added support for Rails API
- Added support for Amazon STS
- Fixed replica check when `hot_standby = on` for primary

## 1.6.4

- Only show connection charts if there are connections
- Fixed duplicate indexes for multiple schemas
- Fixed display issue for queries without word break
- Removed maintenance tab for replicas

## 1.6.3

- Added 10 second timeout for explain
- No longer show autovacuum in long running queries
- Added charts for connections
- Added new config format
- Removed Chartkick gem dependency for charts
- Fixed error when primary database is not PostgreSQL

## 1.6.2

- Suggest GiST over GIN for `LIKE` queries again (seeing better performance)

## 1.6.1

- Suggest GIN over GiST for `LIKE` queries

## 1.6.0

- Removed mostly inactionable items (cache hit rate and index usage)
- Restored duplicate indexes to homepage
- Fixed issue with exact duplicate indexes
- Way better `blocked_queries` method

## 1.5.3

- Fixed Rails 5 error with multiple databases
- Fixed duplicate index detection with expressions

## 1.5.2

- Added support for PostgreSQL 9.6
- Fixed incorrect query start for live queries in transactions

## 1.5.1

- Better tune page for PostgreSQL 9.5

## 1.5.0

- Added user to query stats (opt-in)
- Added user to connection sources
- Added `capture_space_stats` method and rake task
- Added visualize button to explain page
- Better charts for system stats

## 1.4.2

- Fixed `wrong constant name` error in development
- Added different periods for system stats

## 1.4.1

- Removed external assets

## 1.4.0

- Updated for Rails 5
- Fixed error when `pg_stat_statements` not enabled in `shared_libaries`

## 1.3.2

- Improved performance of query stats

## 1.3.1

- Improved grouping of query stats
- Added `blocked_queries` method

## 1.3.0

- Added query hash for better query stats grouping
- Added sequence danger check
- Added `capture_query_stats` option to config

## 1.2.4

- Fixed user methods

## 1.2.3

- Added schema to queries
- Fixed deprecation warning on Rails 5
- Fix for pg_query >= 0.9.0

## 1.2.2

- Better suggested indexes
- Removed duplicate indexes noise
- Fixed partial and expression indexes

## 1.2.1

- Better suggested indexes
- Removed unused indexes noise
- Removed autovacuum danger noise
- Removed maintenance tab
- Fixed suggested indexes for replicas
- Fixed issue w/ suggested indexes where same table name exists in multiple schemas

## 1.2.0

- Added suggested indexes
- Added duplicate indexes
- Added maintenance tab
- Added load stats for RDS
- Added `table_caching` and `index_caching` methods
- Added configurable cache hit rate threshold
- Show all connections in connections tab

## 1.1.4

- Added check for transaction ID wraparound failure
- Added check for autovacuum danger

## 1.1.3

- Fixed system stats

## 1.1.2

- Added invalid indexes
- Fixed RDS stats for aws-sdk 2

## 1.1.1

- Added `tables` option to `create_user` method
- Added ability to sort query stats by average_time and calls
- Only show unused indexes with no index scans in UI

## 1.1.0

- Added historical query stats

## 1.0.1

- Fixed connection bad errors
- Restore previous connection properly for nested with blocks
- Added analyze button to explain page
- Added explain button to live queries page

## 1.0.0

- More platforms!
- Support for multiple databases!
- Added `replica?` method
- Added `replication_lag` method
- Added `ssl_used?` method
- Added `kill_long_running_queries` method
- Added env vars for settings

## 0.1.10

- Added connections page
- Added message for insufficient privilege
- Added `ip` to `connection_sources`

## 0.1.9

- Added tune page
- Removed minimum size for unused indexes

## 0.1.8

- Added `total_percent` to `query_stats`
- Added `total_connections`
- Added `connection_stats` for Amazon RDS

## 0.1.7

- Added support for pg_stat_statments on Amazon RDS
- Added `long_running_query_sec`, `slow_query_ms` and `slow_query_calls` options

## 0.1.6

- Added methods to create and drop users
- Added locks

## 0.1.5

- Added system stats for Amazon RDS
- Added code to remove unused indexes
- Require unused indexes to be at least 1 MB
- Use `pg_terminate_backend` to ensure queries are killed

## 0.1.4

- Reduced long running queries threshold to 1 minute
- Fixed duration
- Fixed wrapping
- Friendlier dependencies for JRuby

## 0.1.3

- Reverted `query_stats_available?` fix

## 0.1.2

- Fixed `query_stats_available?` method

## 0.1.1

- Added explain
- Added query stats
- Fixed CSS issues

## 0.1.0

- First major release
