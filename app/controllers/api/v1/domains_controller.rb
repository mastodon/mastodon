# frozen_string_literal: true

class Api::V1::DomainsController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action -> { doorkeeper_authorize! :write }
  before_action :require_user!

  respond_to :json

  def blocks
    @domains = AccountDomainBlock.where(account: current_account)
  end

  def block
    AccountDomainBlockService.new.call(current_user.account, params[:domain])

    @domains = AccountDomainBlock.where(account: current_account)
    render action: :index
  end

  def unblock
    AccountDomainUnblockService.new.call(current_user.account, params[:domain])

    @domains = AccountDomainBlock.where(account: current_account)
    render action: :index
  end
end
