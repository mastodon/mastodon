module Subscription
  class StripeSubscription < ApplicationRecord
    belongs_to :user, optional: true
    belongs_to :invite, optional: true
    attr_accessor :subscription

    validates :status, presence: true
  end
end
