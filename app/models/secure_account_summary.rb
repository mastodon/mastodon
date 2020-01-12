# frozen_string_literal: true

class SecureAccountSummary < ApplicationRecord
  belongs_to :account
  attr_encrypted :summary, key: Rails.configuration.x.otp_secret[0...32]
end
