# frozen_string_literal: true

module RemoteAccountControllerConcern
  extend ActiveSupport::Concern

  included do
    layout 'public'
    before_action :set_account
    before_action :check_account_suspension
  end

  private

  def set_account
    @account = Account.find_remote!(params[:acct])
  end

  def check_account_suspension
    gone if @account.suspended?
  end
end
