# frozen_string_literal: true

class Auth::ConfirmationsController < Devise::ConfirmationsController
  layout 'auth'

  def show
    super do |user|
      BootstrapTimelineWorker.perform_async(user.account_id) if user.errors.empty?
    end
  end
end
