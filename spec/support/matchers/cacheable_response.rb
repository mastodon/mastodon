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
    "Response `Vary` header does not contain `#{@expected_vary}`" unless @response.headers['Vary'].include?(@expected_vary)
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
