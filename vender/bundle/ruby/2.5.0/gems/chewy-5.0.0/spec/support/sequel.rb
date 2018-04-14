require 'database_cleaner'

DB = Sequel.sqlite # logger: Logger.new(STDERR)
Sequel::Deprecation.output = false

DB.create_table :countries do
  primary_key :id
  column :name, :string
  column :country_code, :string
  column :rating, :integer
  column :updated_at, :datetime
end

DB.create_table :cities do
  primary_key :id
  column :country_id, :integer
  column :name, :string
  column :rating, :integer
  column :updated_at, :datetime
end

DB.create_table :rating_cities do
  primary_key :rating
  column :country_id, :integer
  column :name, :string
  column :updated_at, :datetime
end

Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :chewy_observe

module SequelClassHelpers
  extend ActiveSupport::Concern

  class AdaptedSequelModel < Sequel::Model
    # Allow to set primary key using mass assignment.
    unrestrict_primary_key

    # Aliases for compatibility with specs that were written with ActiveRecord in mind...
    alias_method :save!, :save
    alias_method :update_attributes, :update
    alias_method :update_attributes!, :update

    class << self
      alias_method :create!, :create
    end
  end

  def adapter
    :sequel
  end

  def stub_model(name, &block)
    stub_class(name, AdaptedSequelModel, &block).tap do |klass|
      # Sequel doesn't work well with dynamically created classes,
      # so we must set the dataset (table) name manually.
      klass.dataset = name.to_s.pluralize.to_sym
    end
  end
end

RSpec.configure do |config|
  config.include SequelClassHelpers

  config.filter_run_excluding :active_record
  config.filter_run_excluding :mongoid

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
