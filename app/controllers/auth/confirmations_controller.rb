# frozen_string_literal: true

class Auth::ConfirmationsController < Devise::ConfirmationsController
  layout 'auth'
  before_action :set_pack

  def show
    super do |user|
      BootstrapTimelineWorker.perform_async(user.account_id) if user.errors.empty?
    end
  end
  
  private

  def set_pack
    use_pack 'auth'
  end
end
