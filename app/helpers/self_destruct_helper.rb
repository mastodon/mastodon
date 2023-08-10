# frozen_string_literal: true

module SelfDestructHelper
  def self.self_destruct?
    ENV.fetch('SELF_DESTRUCT', nil).present? && Rails.application.message_verifier('self-destruct').verify(ENV.fetch('SELF_DESTRUCT', nil)) == ENV['LOCAL_DOMAIN']
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    false
  end

  def self_destruct?
    SelfDestructHelper.self_destruct?
  end
end
