# frozen_string_literal: true

module JitteredRetryIn
  extend ActiveSupport::Concern

  included do
    sidekiq_retry_in do |count|
      # This is the same as the default Sidekiq implementation of delay_for,
      # but with a random 50% more jitter.
      ((15 + count**4) * (1 + rand(0..0.5))).floor
    end
  end
end
