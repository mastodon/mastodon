# frozen_string_literal: true

module ActivityPub
  module Identifier
    extend ActiveSupport::Concern

    included do
      before_validation :generate_global_identifier,
                        only: :create,
                        unless: :uri?
    end

    private

    def generate_global_identifier
      self.uri = ActivityPub::TagManager
                 .instance
                 .generate_activity_uri
    end
  end
end
