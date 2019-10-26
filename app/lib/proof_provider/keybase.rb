# frozen_string_literal: true

class ProofProvider::Keybase
  BASE_URL = ENV.fetch('KEYBASE_BASE_URL', 'https://keybase.io')
  DOMAIN   = ENV.fetch('KEYBASE_DOMAIN', Rails.configuration.x.web_domain)

  class Error < StandardError; end

  class ExpectedProofLiveError < Error; end

  class UnexpectedResponseError < Error; end

  def initialize(proof = nil)
    @proof = proof
  end

  def serializer_class
    ProofProvider::Keybase::Serializer
  end

  def worker_class
    ProofProvider::Keybase::Worker
  end

  def validate!
    unless @proof.token&.size == 66
      @proof.errors.add(:base, I18n.t('identity_proofs.errors.keybase.invalid_token'))
      return
    end

    # Do not perform synchronous validation for remote accounts
    return if @proof.provider_username.blank? || !@proof.account.local?

    if verifier.valid?
      @proof.verified = true
      @proof.live     = false
    else
      @proof.errors.add(:base, I18n.t('identity_proofs.errors.keybase.verification_failed', kb_username: @proof.provider_username))
    end
  end

  def refresh!
    worker_class.new.perform(@proof)
  rescue ProofProvider::Keybase::Error
    nil
  end

  def on_success_path(user_agent = nil)
    verifier.on_success_path(user_agent)
  end

  def badge
    @badge ||= ProofProvider::Keybase::Badge.new(@proof.account.username, @proof.provider_username, @proof.token, domain)
  end

  def verifier
    @verifier ||= ProofProvider::Keybase::Verifier.new(@proof.account.username, @proof.provider_username, @proof.token, domain)
  end

  private

  def domain
    if @proof.account.local?
      DOMAIN
    else
      @proof.account.domain
    end
  end
end
