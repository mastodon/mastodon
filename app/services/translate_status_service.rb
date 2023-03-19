# frozen_string_literal: true

class TranslateStatusService < BaseService
  CACHE_TTL = 1.day.freeze

  include ERB::Util
  include FormattingHelper

  def call(status, target_language)
    @status = status
    @source_texts = source_texts
    @target_language = target_language

    raise Mastodon::NotPermittedError unless permitted?

    status_translation = Rails.cache.fetch("translations/#{@status.language}/#{@target_language}/#{content_hash}", expires_in: CACHE_TTL) do
      translations = translation_backend.translate(@source_texts.values, @status.language, @target_language)
      build_status_translation(translations)
    end

    status_translation.status = @status

    status_translation
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
    Digest::SHA256.base64digest(@source_texts.transform_keys { |key| key.respond_to?(:id) ? "#{key.class}-#{key.id}" : key }.to_json)
  end

  def source_texts
    texts = {}
    texts[:content] = prerender_custom_emojis(status_content_format(@status)) if @status.content.present?
    texts[:spoiler_text] = prerender_custom_emojis(@status.spoiler_text) if @status.spoiler_text.present?

    @status.preloadable_poll&.loaded_options&.each do |option|
      texts[option] = prerender_custom_emojis(option.title)
    end

    @status.media_attachments.each do |media_attachment|
      texts[media_attachment] = media_attachment.description
    end

    texts
  end

  def build_status_translation(translations)
    status_translation = StatusTranslation.new(
      detected_source_language: translations.first&.detected_source_language,
      language: @target_language,
      provider: translations.first&.provider,
      poll_options: [],
      media_attachments: []
    )

    @source_texts.keys.each_with_index do |source, index|
      translation = translations[index]

      case source
      when :content
        status_translation.content = detect_custom_emojis(translation.text).to_html
      when :spoiler_text
        status_translation.spoiler_text = detect_custom_emojis(translation.text).content
      when Poll::Option
        status_translation.poll_options << StatusTranslation::Option.new(
          title: detect_custom_emojis(translation.text).content
        )
      when MediaAttachment
        status_translation.media_attachments << StatusTranslation::MediaAttachment.new(
          id: source.id,
          description: translation.text
        )
      end
    end

    status_translation
  end

  def prerender_custom_emojis(text)
    EmojiFormatter.new(html_escape(text), @status.emojis, { data_shortcode: true }).to_s
  end

  def detect_custom_emojis(html)
    fragment = Nokogiri::HTML.fragment(html)
    fragment.css('img[data-shortcode]').each do |element|
      node = Nokogiri::XML::Text.new(":#{element['data-shortcode']}:", fragment.document)
      element.replace(node)
    end
    fragment
  end
end
