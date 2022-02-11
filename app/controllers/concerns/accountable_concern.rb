# frozen_string_literal: true

module AccountableConcern
  extend ActiveSupport::Concern

  def log_action(action, target, options = {})
    Admin::ActionLog.create(account: current_account, action: action, target: target, recorded_changes: options.stringify_keys)
  end
end
