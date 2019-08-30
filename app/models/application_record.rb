# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Remotable

  def boolean_with_default(key, default_value)
    value = attributes[key]

    if value.nil?
      default_value
    else
      value
    end
  end
end
