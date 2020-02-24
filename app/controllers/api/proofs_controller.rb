# frozen_string_literal: true

class Api::ProofsController < Api::BaseController
  before_action :set_account
  before_action :set_provider
  before_action :check_account_approval
  before_action :check_account_suspension

  def index
    render json: @account, serializer: @provider.serializer_class
  end

  private

  def set_provider
    @provider = ProofProvider.find(params[:provider]) || raise(ActiveRecord::RecordNotFound)
  end

  def set_account
    @account = Account.find_local!(params[:username])
  end

  def check_account_approval
    not_found if @account.user_pending?
  end

  def check_account_suspension
    gone if @account.suspended?
  end
end
