require_relative "core"

# Groups timeout exceptions in rollbar by exception class, http method, and url.
#
# Usage: after requiring rollbar (say, in your rollbar initializer file), call:
#
#   require "rack/timeout/rollbar"
#
# Ruby 2.1 is required as we use `Module.prepend`.
#
# To use a custom fingerprint for grouping:
#
#   Rack::Timeout::Rollbar.fingerprint do |exception, env|
#     # … return some kind of string derived from exception and env
#   end

module Rack::Timeout::Rollbar

  def self.fingerprint(&block)
    define_method(:rack_timeout_fingerprint) { |exception, env| block[exception, env] }
  end

  def self.default_rack_timeout_fingerprint(exception, env)
    request = ::Rack::Request.new(env)
    [ exception.class.name,
      request.request_method,
      request.path
    ].join(" ")
  end

  fingerprint &method(:default_rack_timeout_fingerprint)


  def build_payload(level, message, exception, extra)
    payload = super(level, message, exception, extra)

    return payload unless exception.is_a?(::Rack::Timeout::ExceptionWithEnv) \
                       && payload.respond_to?(:[])                           \
                       && payload.respond_to?(:[]=)

    data = payload["data"]
    return payload unless data.respond_to?(:[]=)

    payload             = payload.dup
    data                = data.dup
    data["fingerprint"] = rack_timeout_fingerprint(exception, exception.env)
    payload["data"]     = data

    return payload
  end
end

::Rollbar::Notifier.prepend ::Rack::Timeout::Rollbar
