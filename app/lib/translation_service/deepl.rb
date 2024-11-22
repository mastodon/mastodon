# frozen_string_literal: true

class TranslationService::DeepL < TranslationService
  include JsonLdHelper

  def initialize(plan, api_key)
    super()

    @plan    = plan
    @api_key = api_key
  end

  def translate(texts, source_language, target_language)
    form = { text: texts, source_lang: source_language&.upcase, target_lang: target_language, tag_handling: 'html' }
    request(:post, '/v2/translate', form: form) do |res|
      transform_response(res.body_with_limit)
    end
  end

  def languages
    source_languages = [nil] + fetch_languages('source')

    # In DeepL, EN and PT are deprecated in favor of EN-GB/EN-US and PT-BR/PT-PT, so
    # they are supported but not returned by the API.
    target_languages = %w(en pt) + fetch_languages('target')

    source_languages.index_with { |language| target_languages.without(nil, language) }
  end

  private

  def fetch_languages(type)
    request(:get, "/v2/languages?type=#{type}") do |res|
      Oj.load(res.body_with_limit).map { |language| normalize_language(language['language']) }
    end
  end

  def normalize_language(language)
    subtags = language.split(/[_-]/)
    subtags[0].downcase!
    subtags[1]&.upcase!
    subtags.join('-')
  end

  def request(verb, path, **)
    req = Request.new(verb, "#{base_url}#{path}", **)
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

  def transform_response(json)
    data = Oj.load(json, mode: :strict)
    raise UnexpectedResponseError unless data.is_a?(Hash)

    data['translations'].map do |translation|
      Translation.new(
        text: translation['text'],
        detected_source_language: translation['detected_source_language']&.downcase,
        provider: 'DeepL.com'
      )
    end
  rescue Oj::ParseError
    raise UnexpectedResponseError
  end
end
