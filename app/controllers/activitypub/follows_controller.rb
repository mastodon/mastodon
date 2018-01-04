# frozen_string_literal: true

class ActivityPub::FollowsController < Api::BaseController
  include SignatureVerification

  def show
    render json: follow_request,
           serializer: ActivityPub::FollowSerializer,
           adapter: ActivityPub::Adapter,
           content_type: 'application/activity+json'
  end

  private

  def follow_request
    FollowRequest.includes(:account).references(:account).find_by!(
      id: params.require(:id),
      accounts: { domain: nil, username: params.require(:account_username) },
      target_account: signed_request_account
    )
  end
end
