# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Remotable

  connects_to database: { writing: :primary, reading: ENV['REPLICA_DB_NAME'] || ENV['REPLICA_DATABASE_URL'] ? :replica : :primary }

  class << self
    def update_index(_type_name, *_args, &_block)
      super if Chewy.enabled?
    end
  end

  def boolean_with_default(key, default_value)
    value = attributes[key]

    if value.nil?
      default_value
    else
      value
    end
  end
end
