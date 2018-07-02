# frozen_string_literal: true

module Expireable
  extend ActiveSupport::Concern

  included do
    scope :expired, -> { where.not(expires_at: nil).where('expires_at < ?', Time.now.utc) }

    attr_reader :expires_in

    def expires_in=(interval)
      self.expires_at = interval.to_i.seconds.from_now unless interval.blank?
      @expires_in     = interval
    end

    def expire!
      touch(:expires_at)
    end

    def expired?
      !expires_at.nil? && expires_at < Time.now.utc
    end
  end
end
