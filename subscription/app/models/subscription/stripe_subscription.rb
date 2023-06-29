module Subscription
  class StripeSubscription < ApplicationRecord
    enum status: [ :inactive, :active, :trial ]
    belongs_to :user, optional: true
    belongs_to :invite, optional: true
    attr_accessor :subscription
  end
end
