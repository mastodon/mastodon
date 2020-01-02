# frozen_string_literal: true

class HandleBadEncodingMiddleware
  SANITIZE_ENV_KEYS = %w(
    HTTP_REFERER
    PATH_INFO
    REQUEST_URI
    REQUEST_PATH
    QUERY_STRING
  ).freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    SANITIZE_ENV_KEYS.each do |key|
      str = CGI.unescape(env[key].to_s).force_encoding('UTF-8')
      return [400, {}, ['Bad request']] unless str.valid_encoding?
    end

    begin
      request = Rack::Request.new(env.dup)
      request.params
    rescue ArgumentError => e
      if e.message =~ /invalid %-encoding/
        return [400, {}, ['Bad request']]
      else
        raise e
      end
    end

    @app.call(env)
  end
end
