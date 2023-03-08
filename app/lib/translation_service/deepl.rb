# frozen_string_literal: true

class TranslationService::DeepL < TranslationService
  include JsonLdHelper

  def initialize(plan, api_key)
    super()

    @plan    = plan
    @api_key = api_key
  end

  def translate(text, source_language, target_language)
    form = { text: text, source_lang: source_language&.upcase, target_lang: target_language, tag_handling: 'html' }
    request(:post, '/v2/translate', form: form) do |res|
      transform_response(res.body_with_limit)
    end
  end

  def target_languages(source_language)
    return [] unless languages('source').include?(source_language)

    languages('target').without(source_language)
  end

  private

  def languages(type)
    Rails.cache.fetch("translation_service/deepl/languages/#{type}", expires_in: 7.days, race_condition_ttl: 1.minute) do
      request(:get, "/v2/languages?type=#{type}") do |res|
        # In DeepL, EN and PT are deprecated in favor of EN-GB/EN-US and PT-BR/PT-PT, so
        # they are supported but not returned by the API.
        extra = type == 'source' ? [nil] : %w(en pt)
        languages = Oj.load(res.body_with_limit).map { |language| language['language'].downcase }

        languages + extra
      end
    end
  end

  def request(verb, path, **options)
    req = Request.new(verb, "#{base_url}#{path}", **options)
    req.add_headers(Authorization: "DeepL-Auth-Key #{@api_key}")
    req.perform do |res|
      case res.code
      when 429
        raise TooManyRequestsError
      when 456
        raise QuotaExceededError
      when 200...300
        yield res
      else
        raise UnexpectedResponseError
      end
    end
  end

  def base_url
    if @plan == 'free'
      'https://api-free.deepl.com'
    else
      'https://api.deepl.com'
    end
  end

  def transform_response(str)
    json = Oj.load(str, mode: :strict)

    raise UnexpectedResponseError unless json.is_a?(Hash)

    Translation.new(text: json.dig('translations', 0, 'text'), detected_source_language: json.dig('translations', 0, 'detected_source_language')&.downcase, provider: 'DeepL.com')
  rescue Oj::ParseError
    raise UnexpectedResponseError
  end
end
