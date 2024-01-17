# frozen_string_literal: true

class REST::FollowRequestedAccountSerializer < REST::AccountSerializer
  attribute :follow_request_created_at

  def follow_request_created_at
    FollowRequest.find_by(account_id: object.id).created_at
  end
end
