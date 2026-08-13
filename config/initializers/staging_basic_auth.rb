# frozen_string_literal: true

# Staging-only: require HTTP Basic Auth for the whole app, except the health
# check (so Elestio's own monitoring doesn't get locked out). Only activates
# when both env vars are set; production/local dev are unaffected.
class StagingBasicAuth
  def initialize(app)
    @app = app
    @user = ENV.fetch('STAGING_BASIC_AUTH_USER', nil)
    @password = ENV.fetch('STAGING_BASIC_AUTH_PASSWORD', nil)
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) if request.path == '/health'

    auth = Rack::Auth::Basic::Request.new(env)

    if auth.provided? && auth.basic? && valid?(*auth.credentials)
      status, headers, body = @app.call(env)
      # Any cache (browser or Elestio's edge proxy) must treat authenticated
      # and unauthenticated requests as different responses -- otherwise a
      # cached authenticated page could be served to someone without
      # credentials, or vice versa.
      headers['Vary'] = [headers['Vary'], 'Authorization'].compact.join(', ')
      [status, headers, body]
    else
      [
        401,
        {
          'Content-Type' => 'text/plain',
          'WWW-Authenticate' => 'Basic realm="Staging"',
          # Must never be cached (by the browser or Elestio's edge proxy) --
          # a cached 401 would keep rejecting correct credentials submitted
          # shortly after within the cache window.
          'Cache-Control' => 'no-store, private, max-age=0',
          'Vary' => 'Authorization',
        },
        ['Authentication required'],
      ]
    end
  end

  private

  def valid?(username, password)
    ActiveSupport::SecurityUtils.secure_compare(username, @user) &
      ActiveSupport::SecurityUtils.secure_compare(password, @password)
  end
end

if ENV['STAGING_BASIC_AUTH_USER'].present? && ENV['STAGING_BASIC_AUTH_PASSWORD'].present?
  Rails.application.config.middleware.use StagingBasicAuth
end
