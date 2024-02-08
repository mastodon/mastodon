# frozen_string_literal: true

module Api::AccessTokenTrackingConcern
  extend ActiveSupport::Concern

  ACCESS_TOKEN_UPDATE_FREQUENCY = 24.hours.freeze

  included do
    before_action :update_access_token_last_used
  end

  private

  def update_access_token_last_used
    doorkeeper_token.update_last_used(request) if access_token_needs_update?
  end

  def access_token_needs_update?
    doorkeeper_token.present? && (doorkeeper_token.last_used_at.nil? || doorkeeper_token.last_used_at < ACCESS_TOKEN_UPDATE_FREQUENCY.ago)
  end
end
