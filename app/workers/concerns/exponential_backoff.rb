# frozen_string_literal: true

module ExponentialBackoff
  extend ActiveSupport::Concern

  included do
    sidekiq_retry_in do |count|
      15 + (10 * (count**4)) + rand(10 * (count**4))
    end
  end
end
