# frozen_string_literal: true

class TranslateStatusService < BaseService
  CACHE_TTL = 1.day.freeze

  include FormattingHelper

  def call(status, target_language)
    @status = status
    @content = status_content_format(@status)
    @target_language = target_language

    raise Mastodon::NotPermittedError unless permitted?

    Rails.cache.fetch("translations/#{@status.language}/#{@target_language}/#{content_hash}", expires_in: CACHE_TTL) { translation_backend.translate(@content, @status.language, @target_language) }
  end

  private

  def translation_backend
    @translation_backend ||= TranslationService.configured
  end

  def permitted?
    return false unless @status.distributable? && @status.content.present? && TranslationService.configured?

    languages[@status.language]&.include?(@target_language)
  end

  def languages
    Rails.cache.fetch('translation_service/languages', expires_in: 7.days, race_condition_ttl: 1.hour) { TranslationService.configured.languages }
  end

  def content_hash
    Digest::SHA256.base64digest(@content)
  end
end
