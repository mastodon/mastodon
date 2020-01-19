# frozen_string_literal: true
# See: https://jamescrisp.org/2018/05/28/fixing-invalid-query-parameters-invalid-encoding-in-a-rails-app/

class HandleBadEncodingMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s)
    rescue Rack::Utils::InvalidParameterError
      env['QUERY_STRING'] = ''
    end

    @app.call(env)
  end
end
