# load schema to in memory sqlite
ActiveRecord::Migration.verbose = false
load Rails.root + 'db/schema.rb'
