# frozen_string_literal: true

module AccountableConcern
  extend ActiveSupport::Concern

  def log_action(action, target)
    current_account
      .action_logs
      .create(action:, target:)
  end
end
