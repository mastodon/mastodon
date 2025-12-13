# frozen_string_literal: true

class OAuth::TokensController < Doorkeeper::TokensController
  def revoke
    unsubscribe_for_token if token.present? && authorized? && token.accessible?

    super
  end

  private

  def unsubscribe_for_token
    Web::PushSubscription.where(access_token_id: token.id).delete_all
  end
end
