# frozen_string_literal: true

class Mastodon::RackMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    response = format_json(env, headers, response)
    [status, headers, response]
  ensure
    clean_up_sockets!
  end

  private

  # If the request is expecting HTML but the response is JSON,
  # pretty-print the json so it can be more easily read
  def format_json(env, headers, response)
    if headers['Content-Type']&.include?('application/json') && env['HTTP_ACCEPT']&.include?('text/html')
      [JSON.pretty_generate(JSON.parse(response.body))]
    else
      response
    end
  end

  def clean_up_sockets!
    clean_up_redis_socket!
    clean_up_statsd_socket!
  end

  def clean_up_redis_socket!
    RedisConfiguration.pool.checkin if Thread.current[:redis]
    Thread.current[:redis] = nil
  end

  def clean_up_statsd_socket!
    Thread.current[:statsd_socket]&.close
    Thread.current[:statsd_socket] = nil
  end
end
