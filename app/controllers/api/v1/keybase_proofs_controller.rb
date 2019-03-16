# frozen_string_literal: true

class Api::V1::KeybaseProofsController < Api::BaseController
  respond_to :json

  def index
    @account = Account.find_local!(params[:username])
    kb_proofs = AccountIdentityProof.keybase.where(account_id: @account.id)

    render json: @account, serializer: REST::KeybaseUserSerializer, proofs: kb_proofs
  end
end
