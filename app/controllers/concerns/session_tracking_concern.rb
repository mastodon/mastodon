# frozen_string_literal: true

module SessionTrackingConcern
  extend ActiveSupport::Concern

  SESSION_UPDATE_FREQUENCY = 24.hours.freeze

  included do
    before_action :set_session_activity
  end

  private

  def set_session_activity
    return unless session_needs_update?

    current_session.touch
  end

  def session_needs_update?
    !current_session.nil? && current_session.updated_at < SESSION_UPDATE_FREQUENCY.ago
  end
end
