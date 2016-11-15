# frozen_string_literal: true

module Targetable
  extend ActiveSupport::Concern

  included do
    def object_type
      :object
    end
  end
end
