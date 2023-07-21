# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Remotable

  connects_to database: { writing: :primary, reading: ENV['DB_REPLICA_NAME'] || ENV['READ_DATABASE_URL'] ? :read : :primary }

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
