# frozen_string_literal: true

RSpec::Matchers.define :have_cacheable_headers do
  match do |response|
    @response = response

    @errors = [].tap do |errors|
      errors << check_cookies
      errors << check_cookie_headers
      errors << check_session
      errors << check_cache_control
      errors << check_vary if @expected_vary.present?
    end

    @errors.compact.empty?
  end

  chain :with_vary do |string|
    @expected_vary = string
  end

  failure_message do
    <<~ERROR
      Expected that the response would be cacheable but it was not:
        - #{@errors.compact.join("\n  - ")}
    ERROR
  end

  def check_vary
    ALLOWED_EXTRA_VARY_VALUES = %w(Accept-Encoding Origin).freeze
    actual_vary = @response.headers['Vary']&.split(',')&.map(&:strip) || []
    expected_vary = @expected_vary.split(',').map(&:strip)
    missing = expected_vary - actual_vary
    extra = actual_vary - expected_vary
    unexpected = extra.reject { |v| ALLOWED_EXTRA_VARY_VALUES.include?(v) }

    if missing.any?
      "Response `Vary` header does not contain `#{@expected_vary}`"
    elsif unexpected.any?
      "Response `Vary` header contains unexpected values: #{unexpected.inspect}"
    end
  end

  def check_cookies
    'Reponse cookies are present' unless @response.cookies.empty?
  end

  def check_cookie_headers
    'Response `Set-Cookies` headers are present' if @response.headers['Set-Cookies'].present?
  end

  def check_session
    'The session is not empty' unless session.empty?
  end

  def check_cache_control
    'The `Cache-Control` header does not contain `public`' unless @response.headers['Cache-Control'].include?('public')
  end
end
