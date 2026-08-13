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
      @app.call(env)
    else
      [
        401,
        { 'Content-Type' => 'text/plain', 'WWW-Authenticate' => 'Basic realm="Staging"' },
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
