# frozen_string_literal: true

module AccountableConcern
  extend ActiveSupport::Concern

  def log_action(action, target)
    return unless target.previous_changes.any?

    Admin::ActionLog.create(
      account: current_account,
      action: action,
      target: target
    )
  end
end
