# frozen_string_literal: true

module SessionTrackingConcern
  extend ActiveSupport::Concern

  UPDATE_SIGN_IN_HOURS = 24

  included do
    before_action :set_session_activity
  end

  private

  def set_session_activity
    return unless session_needs_update?
    current_session.touch
  end

  def session_needs_update?
    !current_session.nil? && current_session.updated_at < UPDATE_SIGN_IN_HOURS.hours.ago
  end
end
