module PgHero
  class QueryStats < ActiveRecord::Base
    self.abstract_class = true
    self.table_name = "pghero_query_stats"
    establish_connection ENV["PGHERO_STATS_DATABASE_URL"] if ENV["PGHERO_STATS_DATABASE_URL"]
  end
end
