# frozen_string_literal: true

module ActivityPubPayloadGeneration
  extend ActiveSupport::Concern

  included do
    before_validation :generate_payload_uri,
                      only: :create,
                      unless: :uri?
  end

  private

  def generate_payload_uri
    self.uri = ActivityPub::TagManager
               .instance
               .generate_activity_uri
  end
end
