# frozen_string_literal: true

class Api::V1::Accounts::IdentityProofsController < Api::BaseController
  before_action :require_user!
  before_action :set_account

  def index
    @proofs = @account.suspended? ? [] : @account.identity_proofs.active
    render json: @proofs, each_serializer: REST::IdentityProofSerializer
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end
end
