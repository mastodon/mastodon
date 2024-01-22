# frozen_string_literal: true

class TranslationService::LibreTranslate < TranslationService
  def initialize(base_url, api_key)
    super()

    @base_url = base_url
    @api_key  = api_key
  end

  def translate(texts, source_language, target_language)
    body = Oj.dump(q: texts, source: source_language.presence || 'auto', target: target_language, format: 'html', api_key: @api_key)
    request(:post, '/translate', body: body) do |res|
      transform_response(res.body_with_limit, source_language)
    end
  end

  def languages
    request(:get, '/languages') do |res|
      languages = Oj.load(res.body_with_limit).to_h do |language|
        [language['code'], language['targets'].without(language['code'])]
      end
      languages[nil] = languages.values.flatten.uniq.sort
      languages
    end
  end

  private

  def request(verb, path, **options)
    req = Request.new(verb, "#{@base_url}#{path}", allow_local: true, **options)
    req.add_headers('Content-Type': 'application/json')
    req.perform do |res|
      case res.code
      when 429
        raise TooManyRequestsError
      when 403
        raise QuotaExceededError
      when 200...300
        yield res
      else
        raise UnexpectedResponseError
      end
    end
  end

  def transform_response(json, source_language)
    data = Oj.load(json, mode: :strict)
    raise UnexpectedResponseError unless data.is_a?(Hash)

    data['translatedText'].map.with_index do |text, index|
      Translation.new(
        text: text,
        detected_source_language: data.dig('detectedLanguage', index, 'language') || source_language,
        provider: 'LibreTranslate'
      )
    end
  rescue Oj::ParseError
    raise UnexpectedResponseError
  end
end
