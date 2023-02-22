# frozen_string_literal: true

class TranslationService::DeepL < TranslationService
  include JsonLdHelper

  def initialize(plan, api_key)
    super()

    @plan    = plan
    @api_key = api_key
  end

  def translate(text, source_language, target_language)
    request(text, source_language, target_language).perform do |res|
      case res.code
      when 429
        raise TooManyRequestsError
      when 456
        raise QuotaExceededError
      when 200...300
        transform_response(res.body_with_limit)
      else
        raise UnexpectedResponseError
      end
    end
  end

  private

  def request(text, source_language, target_language)
    req = Request.new(:post, endpoint_url, form: { text: text, source_lang: source_language&.upcase, target_lang: target_language, tag_handling: 'html' })
    req.add_headers(Authorization: "DeepL-Auth-Key #{@api_key}")
    req
  end

  def endpoint_url
    if @plan == 'free'
      'https://api-free.deepl.com/v2/translate'
    else
      'https://api.deepl.com/v2/translate'
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
