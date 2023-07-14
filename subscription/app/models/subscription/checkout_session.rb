module Subscription
  class CheckoutSession < ApplicationRecord
    belongs_to :user
    attr_accessor :session
  end
end
