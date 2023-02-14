# frozen_string_literal: true

class TranslationService::LibreTranslate < TranslationService
  def initialize(base_url, api_key)
    super()

    @base_url = base_url
    @api_key  = api_key
  end

  def translate(text, source_language, target_language)
    request(text, source_language, target_language).perform do |res|
      case res.code
      when 429
        raise TooManyRequestsError
      when 403
        raise QuotaExceededError
      when 200...300
        transform_response(res.body_with_limit, source_language)
      else
        raise UnexpectedResponseError
      end
    end
  end

  private

  def request(text, source_language, target_language)
    body = Oj.dump(q: text, source: source_language.presence || 'auto', target: target_language, format: 'html', api_key: @api_key)
    req = Request.new(:post, "#{@base_url}/translate", body: body, allow_local: true)
    req.add_headers('Content-Type': 'application/json')
    req
  end

  def transform_response(str, source_language)
    json = Oj.load(str, mode: :strict)

    raise UnexpectedResponseError unless json.is_a?(Hash)

    Translation.new(text: json['translatedText'], detected_source_language: source_language, provider: 'LibreTranslate')
  rescue Oj::ParseError
    raise UnexpectedResponseError
  end
end
