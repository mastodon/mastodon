## 0.2.2

- Friendlier output
- Better method of hooking into ActiveRecord

## 0.2.1

- Recommend `disable_ddl_transaction!` over `commit_db_transaction`
- Suggest `jsonb` over `json` in Postgres 9.4+
- Changing `varchar` to `text` is safe in Postgres 9.1+
- Do not check number of columns for unique indexes

## 0.2.0

- Added customizable error messages
- Updated instructions for adding a column with a default value

## 0.1.9

- Added `start_after` option

## 0.1.8

- Fixed error with `create_table`
- Added check for executing arbitrary SQL

## 0.1.7

- Added check for `force` option with `create_table`
- Added `auto_analyze` option

## 0.1.6

- Adding an index to a newly created table is now safe

## 0.1.5

- Fixed error with Ruby 2.3 frozen strings

## 0.1.4

- Added alphabetize columns

## 0.1.3

- Disabled dangerous rake tasks in production
- Added ability to use `SAFETY_ASSURED` env var

## 0.1.2

- Skip checks on down migrations and rollbacks
- Added check for indexes with more than 3 columns

## 0.1.1

- Fixed `add_index` check for MySQL

## 0.1.0

- First release
