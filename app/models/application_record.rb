# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Remotable

  connects_to database: { writing: :primary, reading: :replica } if DatabaseHelper.replica_enabled?

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

  # Prevent implicit serialization in ActiveModel::Serializer or other code paths.
  # This is a hardening step to avoid accidental leaking of attributes.
  def as_json
    raise NotImplementedError
  end
end
