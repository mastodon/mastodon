# frozen_string_literal: true

class Api::V1::KeybaseProofsController < Api::BaseController
  respond_to :json

  def index
    @account = Account.find_local!(params[:username])

    @proofs = AccountIdentityProof.keybase.where(account_id: @account.id)
    render json: @proofs, each_serializer: REST::KeybaseProofSerializer, root: 'signatures', adapter: :json
  end

end
