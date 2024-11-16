# frozen_string_literal: true

module SelfDestructHelper
  VERIFY_PURPOSE = 'self-destruct'

  def self.self_destruct?
    value = Rails.configuration.x.mastodon.self_destruct_value
    value.present? && Rails.application.message_verifier(VERIFY_PURPOSE).verify(value) == ENV['LOCAL_DOMAIN']
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    false
  end

  def self_destruct?
    SelfDestructHelper.self_destruct?
  end
end
