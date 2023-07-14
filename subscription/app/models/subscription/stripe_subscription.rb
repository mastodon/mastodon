module Subscription
  class StripeSubscription < ApplicationRecord
    belongs_to :user, optional: true
    belongs_to :invite, optional: true
    attr_accessor :subscription

    validates :status, presence: true
    before_validation :set_invite

    def retrieve
      @stripe_sub ||= ::Stripe::Subscription.retrieve(subscription_id)
    end

    def description
      @product ||= ::Stripe::Product.retrieve(retrieve[:plan][:product])
      @product[:name]
    end

    def size
      retrieve[:quantity]
    end

    private
    def set_invite
      self.invite = ::Invite.find_by(id: invite_id)
    end
  end
end
