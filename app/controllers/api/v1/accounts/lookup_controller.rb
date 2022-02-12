# frozen_string_literal: true

class Api::V1::Accounts::LookupController < Api::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:accounts' }
  before_action :set_account
  before_action :check_account_approval
  before_action :check_account_confirmation

  def show
    render json: @account, serializer: REST::AccountSerializer
  end

  private

  def set_account
    @account = ResolveAccountService.new.call(params[:acct], skip_webfinger: true) || raise(ActiveRecord::RecordNotFound)
  rescue Addressable::URI::InvalidURIError
    raise(ActiveRecord::RecordNotFound)
  end

  def check_account_approval
    raise(ActiveRecord::RecordNotFound) if @account.local? && @account.user_pending?
  end

  def check_account_confirmation
    raise(ActiveRecord::RecordNotFound) if @account.local? && !@account.user_confirmed?
  end
end
