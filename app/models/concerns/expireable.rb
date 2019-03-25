# frozen_string_literal: true

module Expireable
  extend ActiveSupport::Concern

  included do
    scope :expired, -> { where.not(expires_at: nil).where('expires_at < ?', Time.now.utc) }

    attr_reader :expires_in

    def expires_in=(interval)
      self.expires_at = interval.to_i.seconds.from_now if interval.present?
      @expires_in     = interval
    end

    def expire!
      touch(:expires_at)
    end

    def expired?
      expires? && expires_at < Time.now.utc
    end

    def expires?
      !expires_at.nil?
    end
  end
end
