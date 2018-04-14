require 'database_cleaner'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'file::memory:?cache=shared', pool: 10)
ActiveRecord::Base.logger = Logger.new('/dev/null')
ActiveRecord::Base.raise_in_transactional_callbacks = true if ActiveRecord::Base.respond_to?(:raise_in_transactional_callbacks)

ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'countries'")
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'cities'")
ActiveRecord::Schema.define do
  create_table :countries do |t|
    t.column :name, :string
    t.column :country_code, :string
    t.column :rating, :integer
    t.column :updated_at, :datetime
  end

  create_table :cities do |t|
    t.column :country_id, :integer
    t.column :name, :string
    t.column :rating, :integer
    t.column :updated_at, :datetime
  end
end

module ActiveRecordClassHelpers
  extend ActiveSupport::Concern

  def adapter
    :active_record
  end

  def stub_model(name, superclass = nil, &block)
    stub_class(name, superclass || ActiveRecord::Base, &block)
  end
end

RSpec.configure do |config|
  config.include ActiveRecordClassHelpers

  config.filter_run_excluding :mongoid
  config.filter_run_excluding :sequel

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :truncation
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
