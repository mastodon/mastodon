# frozen_string_literal: true

class TranslateStatusService < BaseService
  CACHE_TTL = 1.day.freeze

  include FormattingHelper

  def call(status, target_language)
    raise Mastodon::NotPermittedError unless status.public_visibility? || status.unlisted_visibility?

    @status = status
    @content = status_content_format(@status)
    @target_language = target_language

    Rails.cache.fetch("translations/#{@status.language}/#{@target_language}/#{content_hash}", expires_in: CACHE_TTL) { translation_backend.translate(@content, @status.language, @target_language) }
  end

  private

  def translation_backend
    TranslationService.configured
  end

  def content_hash
    Digest::SHA256.base64digest(@content)
  end
end
