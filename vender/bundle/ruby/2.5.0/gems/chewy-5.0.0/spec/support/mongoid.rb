require 'database_cleaner'

CONFIG = {
  sessions: {
    default: {
      uri: 'mongodb://127.0.0.1:27017/chewy_mongoid_test'
    }
  },
  clients: {
    default: {
      uri: 'mongodb://127.0.0.1:27017/chewy_mongoid_test'
    }
  }
}.freeze

Mongoid.configure do |config|
  config.load_configuration(CONFIG)
end

Mongoid.logger = Logger.new('/dev/null')

module MongoidClassHelpers
  extend ActiveSupport::Concern

  module Document
    def serializable_hash(options = nil)
      hash = super(options)
      hash['id'] = hash.delete('_id') if hash.key?('_id')
      hash
    end
  end

  module Country
    extend ActiveSupport::Concern

    included do
      include Mongoid::Document
      include Mongoid::Timestamps::Updated
      include Document

      field :name, type: String
      field :country_code, type: String
      field :rating, type: Integer
    end
  end

  module City
    extend ActiveSupport::Concern

    included do
      include Mongoid::Document
      include Mongoid::Timestamps::Updated
      include Document

      field :name, type: String
      field :rating, type: Integer
    end
  end

  def adapter
    :mongoid
  end

  def stub_model(name, superclass = nil, &block)
    mixin = "MongoidClassHelpers::#{name.to_s.camelize}".safe_constantize || Mongoid::Document

    model = stub_class(name, superclass) do
      include mixin
      store_in collection: name.to_s.tableize
    end
    model.tap { |i| i.class_eval(&block) if block }
  end
end

RSpec.configure do |config|
  config.include MongoidClassHelpers

  config.filter_run_excluding :active_record
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
