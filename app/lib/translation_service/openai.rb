# frozen_string_literal: true

class TranslationService::OpenAI < TranslationService
  def initialize(base_url, api_key, model)
    super()

    @base_url = base_url
    @api_key  = api_key # Optional: Can be nil for endpoints that don't require authentication
    @model    = model
  end

  def translate(texts, source_language, target_language)
    prompt = I18n.t('translation_service.openai.prompt',
                    source_language: source_language.presence || I18n.t('translation_service.openai.auto_detected_language'),
                    target_language: target_language)

    body = Oj.dump(
      model: @model,
      messages: [
        {
          role: 'system',
          content: prompt,
        },
        {
          role: 'user',
          content: texts.first,
        },
      ]
    )

    request(:post, '/v1/chat/completions', body: body) do |res|
      transform_response(res.body_with_limit, source_language.presence)
    end
  end

  def languages
    # Use language codes from LanguagesHelper
    language_codes = LanguagesHelper::SUPPORTED_LOCALES.keys.map(&:to_s)

    # Filter out any non-string elements and regional variants for compatibility
    filtered_codes = language_codes.select { |code| code.is_a?(String) && !code.include?('-') }

    # All languages can translate to all other languages
    languages_map = filtered_codes.index_with { |_| filtered_codes.dup }

    # Add auto-detection (nil key)
    languages_map[nil] = filtered_codes

    languages_map
  end

  private

  def request(verb, path, **)
    req = Request.new(verb, "#{@base_url}#{path}", **)
    req.add_headers('Content-Type': 'application/json')

    # Only add Authorization header if API key is present
    req.add_headers(Authorization: "Bearer #{@api_key}") if @api_key.present?

    req.perform do |res|
      case res.code
      when 429
        raise TooManyRequestsError
      when 401, 403
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
    raise UnexpectedResponseError unless data.is_a?(Hash) && data['choices'].is_a?(Array) && data['choices'].first['message'].is_a?(Hash)

    translated_content = data['choices'].first['message']['content']

    [
      Translation.new(
        text: translated_content.strip,
        detected_source_language: source_language,
        provider: I18n.t('translation_service.openai.provider_name')
      ),
    ]
  rescue Oj::ParseError
    raise UnexpectedResponseError
  end
end
