# frozen_string_literal: true

class OAuth::TokensController < Doorkeeper::TokensController
  include Redisable

  def revoke
    unsubscribe_for_token if token.present? && authorized? && token.accessible?

    super
  end

  private

  def unsubscribe_for_token
    Web::PushSubscription.where(access_token_id: token.id).delete_all
  end

  # This is used to record with which application the user was created
  def after_successful_authorization(context)
    update_user_created_by_application_id(context.auth&.token)

    super
  end

  def update_user_created_by_application_id(token)
    user_id = token&.resource_owner_id
    return if user_id.nil?

    created_by_application_id = redis.get("track_created_by_application_id:#{user_id}")&.to_i

    return if created_by_application_id.nil? || created_by_application_id != token.application_id

    user = User.find_by(id: token.resource_owner_id)
    return if user.nil?

    user.update(created_by_application_id:)
  end
end
