module Subscription
  class Api::InvitesController < ::Api::BaseController
    before_action -> { doorkeeper_authorize! :read }, only: [:index]
    before_action :require_user!

    def index
      @subscriptions = Subscription::StripeSubscription.active.where(user_id: current_account.user.id).where.not(invite_id: nil)
      @invites =  @subscriptions.map(&:invite)
      render json: @invites, each_serializer: REST::InviteSerializer
    end
  end
end
