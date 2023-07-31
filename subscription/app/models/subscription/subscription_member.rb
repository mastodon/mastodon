module Subscription
  class SubscriptionMember < ApplicationRecord
    self.table_name = 'subscription_members'
    belongs_to :user
    belongs_to :subscription, class_name: 'Subscription::StripeSubscription', foreign_key: 'subscription_id'
  end
end