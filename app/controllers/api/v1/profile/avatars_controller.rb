# frozen_string_literal: true

class Api::V1::Profile::AvatarsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!

  def destroy
    @account = current_account
    UpdateAccountService.new.call(@account, { avatar: nil }, raise_error: true)
    ActivityPub::UpdateDistributionWorker.perform_async(@account.id)
    render json: @account, serializer: REST::CredentialAccountSerializer
  end
end
